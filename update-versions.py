import re
import requests
import hashlib
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

def calculate_hash(url):
    try:
        response = requests.get(url, stream=True, timeout=30)
        response.raise_for_status()
        sha256_hash = hashlib.sha256()
        for chunk in response.iter_content(chunk_size=8192):
            sha256_hash.update(chunk)
        return sha256_hash.hexdigest()
    except requests.RequestException as e:
        print(f"Error calculating hash for {url}: {e}")
        return None

def update_file(filename, package, new_version, new_hash):
    try:
        with open(filename, 'r') as file:
            content = file.read()

        version_pattern = rf'{package.upper()}_VERSION=([^\n]+)'
        hash_pattern = rf'{package.upper()}_HASH=([^\n]+)'

        version_match = re.search(version_pattern, content)
        hash_match = re.search(hash_pattern, content)

        if not version_match or not hash_match:
            print(f"Version or hash pattern not found for {package} in {filename}")
            return

        current_version = version_match.group(1)
        current_hash = hash_match.group(1)

        if current_version == new_version and current_hash == new_hash:
            print(f"No update needed for {package} in {filename} (current version: {current_version}, current hash: {current_hash})")
            return

        updated_content = re.sub(version_pattern, f'{package.upper()}_VERSION={new_version}', content)
        updated_content = re.sub(hash_pattern, f'{package.upper()}_HASH={new_hash}', updated_content)

        with open(filename, 'w') as file:
            file.write(updated_content)
        print(f"Updated {package} version from {current_version} to {new_version} and hash from {current_hash} to {new_hash} in {filename}")
    except IOError as e:
        print(f"Error updating {filename}: {e}")

def main():
    packages = {
        'nix': 'NixOS/nix',
        'nixpkgs': 'NixOS/nixpkgs'
    }

    for package, repo in packages.items():
        latest_version = get_latest_version(repo)
        if latest_version:
            filename = f'{package}-setup.sh'
            if package == 'nix':
                url = f"https://github.com/{repo}/archive/{latest_version}/nix-{latest_version}.tar.gz"
            else:
                url = f"https://github.com/{repo}/archive/{latest_version}/nixos-{latest_version}.tar.gz"
            new_hash = calculate_hash(url)
            if new_hash:
                update_file(filename, package, latest_version, new_hash)
            else:
                print(f"Skipping update for {package} due to hash calculation failure")
        else:
            print(f"Skipping update for {package} due to version fetch failure")

if __name__ == "__main__":
    main()
