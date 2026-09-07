#!/usr/bin/env python3
import ast
import json
import os
import subprocess
import sys

BLACKLIST = {
    'bazel_tools', 'bazel_skylib', 'rules_python', 'rules_cc', 'rules_proto',
    'rules_foreign_cc', 'gregistry', 'gregistry_pip_deps', 'chipdev_pip_deps',
    'project_python', 'python3', 'internal_platforms_do_not_use',
    'rules_java_builtin', 'com_google_protobuf', 'abseil-cpp', 'googletest',
    'com_github_fmtlib_fmt', 'com_github_gabime_spdlog', 'boringssl',
    'rules_pkg', 'zlib'
}

def get_bazel_info():
    try:
        # Run bazel info to get output_base and workspace
        result = subprocess.run(
            ['bazel', 'info'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
        info = {}
        for line in result.stdout.splitlines():
            if ':' in line:
                key, val = line.split(':', 1)
                info[key.strip()] = val.strip()
        return info
    except subprocess.CalledProcessError as e:
        print(f"Error running bazel info: {e.stderr}", file=sys.stderr)
        return None

def parse_resolved_deps(bzl_path):
    if not os.path.exists(bzl_path):
        print(f"Warning: {bzl_path} not found.", file=sys.stderr)
        return {}

    with open(bzl_path, 'r') as f:
        content = f.read()

    try:
        tree = ast.parse(content)
        for node in ast.walk(tree):
            if isinstance(node, ast.Assign):
                for target in node.targets:
                    if isinstance(target, ast.Name) and target.id == '_DEPS':
                        # Convert AST dict to python dict
                        return ast.literal_eval(node.value)
    except Exception as e:
        print(f"Error parsing {bzl_path}: {e}", file=sys.stderr)
    return {}

def has_hdl_files(path):
    # Quick check if directory has any HDL files
    # We walk but limit depth/directories to avoid getting stuck.
    # We must follow symlinks because gregistry often uses symlinks for design/dv dirs.
    for root, dirs, files in os.walk(path, followlinks=True):
        # Don't go into dot directories or common non-hdl dirs
        dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ('bazel-out', 'bazel-bin', 'external', 'tests', 'docs', 'html')]
        for f in files:
            if f.endswith(('.sv', '.v', '.svh', '.vh')):
                return True
    return False

def find_weaver_dirs(workspace_root):
    weaver_dirs = []
    bazel_out = os.path.join(workspace_root, 'bazel-out')
    if not os.path.exists(bazel_out):
        return weaver_dirs
        
    for root, dirs, files in os.walk(bazel_out, followlinks=True):
        rel_path = os.path.relpath(root, bazel_out)
        if rel_path == '.':
            pass
        else:
            parts = rel_path.split(os.sep)
            if len(parts) == 1:
                # Inside config dir, only keep bin
                dirs[:] = [d for d in dirs if d == 'bin']
            elif len(parts) >= 2:
                if 'weaver' in dirs:
                    weaver_path = os.path.join(root, 'weaver')
                    if has_hdl_files(weaver_path):
                        weaver_dirs.append(weaver_path)
                    dirs.remove('weaver')
                
                # Prune other common noisy dirs
                dirs[:] = [d for d in dirs if d not in ('_objs', '_virtual_includes', 'external')]
                
    return weaver_dirs

def find_hdl_source_dirs(dep_dir):
    source_dirs = []
    target_names = {'design', 'src', 'rtl', 'interface', 'lib', 'hdl', 'wrappers', 'sv_replace'}
    
    for root, dirs, files in os.walk(dep_dir, followlinks=True):
        # Prune during walk to avoid entering them
        dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ('bazel-out', 'bazel-bin', 'external', 'tests', 'docs', 'html', 'sim', '_objs', '_virtual_includes', '__pycache__', 'tb', 'dv', 'verif', 'fpv', 'testbench', 'verification', 'test', 'bench')]
        
        basename = os.path.basename(root)
        if basename in target_names:
            if has_hdl_files(root):
                source_dirs.append(root)
                dirs[:] = [] # Stop walking deeper
                
    if not source_dirs:
        if has_hdl_files(dep_dir):
            source_dirs.append(dep_dir)
            
    return source_dirs

def generate_slang_config():
    print("Generating Slang LSP configuration...")
    
    bazel_info = get_bazel_info()
    if not bazel_info:
        print("Error: Could not get Bazel info. Make sure you are in a Bazel workspace and bazel is working.", file=sys.stderr)
        return 1

    workspace_root = bazel_info.get('workspace')
    output_base = bazel_info.get('output_base')
    
    if not workspace_root or not output_base:
        print("Error: Missing workspace or output_base from bazel info.", file=sys.stderr)
        return 1

    bzl_path = os.path.join(workspace_root, 'resolved_deps.bzl')
    deps = parse_resolved_deps(bzl_path)
    
    if not deps:
        print("No dependencies found in resolved_deps.bzl (or file missing).", file=sys.stderr)
    
    include_dirs = []
    
    # Add local directories at root that are not hidden, bazel-*, or non-HDL dirs
    exclude_root_dirs = {'external', '__pycache__', 'node_modules', 'venv', '.venv', 'tests', 'docs', 'html'}
    for entry in os.scandir(workspace_root):
        if entry.is_dir():
            name = entry.name
            if not name.startswith('.') and not name.startswith('bazel-') and name not in exclude_root_dirs:
                include_dirs.append(name)
            
    if not include_dirs:
        print("Warning: No local directories found in workspace root.", file=sys.stderr)
        
    # Find and add generated weaver directories
    weaver_dirs = find_weaver_dirs(workspace_root)
    if weaver_dirs:
        print(f"Found {len(weaver_dirs)} generated weaver directories. Adding them to index.")
        include_dirs.extend(weaver_dirs)
    
    missing_deps = []
    
    for dep_name, dep_info in deps.items():
        if dep_name == 'ROOT' or dep_name in BLACKLIST:
            continue
            
        version_or_path = dep_info[0]
        dep_path = None
        
        if version_or_path.startswith('/'):
            # Local dependency
            dep_path = version_or_path
        else:
            # External dependency
            dep_path = os.path.join(output_base, 'external', dep_name)
            
        if dep_path:
            if os.path.exists(dep_path):
                source_dirs = find_hdl_source_dirs(dep_path)
                if source_dirs:
                    include_dirs.extend(source_dirs)
            else:
                missing_deps.append(dep_name)

    if missing_deps:
        print(f"Warning: The following dependencies are not fetched yet (run bazel fetch/build):")
        print(f"  {', '.join(missing_deps)}")
        for dep_name in missing_deps:
            dep_info = deps[dep_name]
            version_or_path = dep_info[0]
            if not version_or_path.startswith('/'):
                dep_path = os.path.join(output_base, 'external', dep_name)
                include_dirs.append(dep_path)

    # Prepare server.json
    slang_dir = os.path.join(workspace_root, '.slang')
    os.makedirs(slang_dir, exist_ok=True)
    
    # Ensure waivers.toml and flags.flist exist
    waivers_path = os.path.join(slang_dir, 'waivers.toml')
    if not os.path.exists(waivers_path):
        with open(waivers_path, 'w') as f:
            f.write("# Slang waivers file\n# [[waivers]]\n# file = \"**/*\"\n# error = \"count-resolution\"\n")
        print(f"Created template {waivers_path}")
            
    flags_flist_path = os.path.join(slang_dir, 'flags.flist')
    if not os.path.exists(flags_flist_path):
        with open(flags_flist_path, 'w') as f:
            f.write("// Add manual defines and flags here\n// -D MY_DEFINE\n// +incdir+my/custom/path\n")
        print(f"Created template {flags_flist_path}")
    
    server_json_path = os.path.join(slang_dir, 'server.json')
    
    existing_config = {}
    if os.path.exists(server_json_path):
        try:
            with open(server_json_path, 'r') as f:
                existing_config = json.load(f)
        except Exception as e:
            print(f"Warning: Could not read existing server.json: {e}", file=sys.stderr)

    # Update index (removed 'external' and 'bazel-*' from excludeDirs, added noisy dirs)
    index_entry = {
        "dirs": include_dirs,
        "excludeDirs": [
            ".git",
            "sim",
            "_objs",
            "_virtual_includes",
            "docs",
            "html",
            "__pycache__",
            "testbench",
            "verif",
            "verification",
            "test",
            "bench"
        ]
    }
    
    existing_config["index"] = [index_entry]
    
    # Set or update flags
    if "flags" not in existing_config:
        existing_config["flags"] = "--compat=vcs --waiver-file .slang/waivers.toml -f .slang/flags.flist"
    else:
        flags_str = existing_config["flags"]
        modified = False
        if "--waiver-file" not in flags_str and ".slang/waivers.toml" not in flags_str:
            flags_str += " --waiver-file .slang/waivers.toml"
            modified = True
        if "-f .slang/flags.flist" not in flags_str and ".slang/flags.flist" not in flags_str:
            flags_str += " -f .slang/flags.flist"
            modified = True
        if modified:
            existing_config["flags"] = flags_str
            print("Updated 'flags' in server.json to include waivers.toml and flags.flist")
            
    if "inlayHints" not in existing_config:
        existing_config["inlayHints"] = {
            "orderedInstanceNames": True,
            "wildcardNames": True,
            "funcArgNames": 2
        }

    try:
        with open(server_json_path, 'w') as f:
            json.dump(existing_config, f, indent=2)
        print(f"Successfully generated/updated {server_json_path}")
    except Exception as e:
        print(f"Error writing {server_json_path}: {e}", file=sys.stderr)
        return 1

    return 0

if __name__ == '__main__':
    sys.exit(generate_slang_config())
