import re
import requests
from packaging import version

def get_latest_version(repo):
    url = f"https://api.github.com/repos/{repo}/tags"
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        tags = response.json()
        if repo == 'NixOS/nixpkgs':
            # For nixpkgs, find the latest release tag (e.g., 23.05)
            release_tags = [tag['name'] for tag in tags if re.match(r'^\d+\.\d+$', tag['name'])]
            if release_tags:
                return max(release_tags, key=lambda x: version.parse(x))
            else:
                # Fallback: return the latest tag
                print(f"No release tags found for {repo}, using latest tag instead.")
                return tags[0]['name']
        else:
            # For other repos, return the latest tag
            return tags[0]['name'].lstrip('v')
    except requests.RequestException as e:
        print(f"Error fetching latest version for {repo}: {e}")
        return None

def update_file(filename, package, new_version):
    try:
        with open(filename, 'r') as file:
            content = file.read()

        version_pattern = rf'{package.upper()}_VERSION=([^\n]+)'
        match = re.search(version_pattern, content)
        if not match:
            print(f"Version pattern not found for {package} in {filename}")
            return

        current_version = match.group(1)
        if current_version == new_version:
            print(f"No update needed for {package} in {filename} (current version: {current_version})")
            return

        updated_content = re.sub(version_pattern, f'{package.upper()}_VERSION={new_version}', content)

        with open(filename, 'w') as file:
            file.write(updated_content)
        print(f"Updated {package} version from {current_version} to {new_version} in {filename}")
    except IOError as e:
        print(f"Error updating {filename}: {e}")

def main():
    packages = {
        'nix': 'NixOS/nix',
        'nixos': 'NixOS/nixpkgs'
    }

    for package, repo in packages.items():
        latest_version = get_latest_version(repo)
        if latest_version:
            if package == 'nixos':
                filename = 'nixpkgs-setup.sh'
            else:
                filename = f'{package}-setup.sh'
            update_file(filename, package, latest_version)
        else:
            print(f"Skipping update for {package} due to version fetch failure")

if __name__ == "__main__":
    main()
