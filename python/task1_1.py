import sys
from pathlib import Path
from typing import Union


if len(sys.argv) != 2:
    print(f'Usage: python3 {sys.argv[0]} <file_name>')
    exit(0)

file = sys.argv[1]

class PathExtensionHandler:
    def __init__(self, allowed_extensions: set = None):
        self.allowed_extensions = {ext.lower() for ext in (allowed_extensions or set())}

    def analyze_file(self, file_path: Union[str, Path]):
            path = Path(file_path)
            temp = path.suffixes
            for suffix in temp:
                if not self._validate_extension(suffix):
                    temp.remove(suffix)
            if len(temp) == 0:
                raise Exception("There is no extension!")
            return temp

    def _validate_extension(self, extension: str) -> bool:
            if not self.allowed_extensions:
                return True
            return extension.lower() in self.allowed_extensions

file_extensions = {
    '.txt', '.doc', '.docx', '.pdf', '.xlsx', '.xls', '.csv', '.tsv', '.html', '.htm', 
    '.xml', '.json', '.yaml', '.md', '.rtf', '.odt', '.ppt', '.pptx', '.jpg', '.jpeg', 
    '.png', '.gif', '.bmp', '.tiff', '.webp', '.svg', '.ico', '.mp3', '.wav', '.flac', 
    '.aac', '.ogg', '.m4a', '.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', 
    '.zip', '.tar', '.rar', '.7z', '.gz', '.bz2', '.iso', '.dmg', '.apk', '.exe', '.bin', 
    '.sys', '.dll', '.sh', '.bat', '.ps1', '.cgi', '.py', '.java', '.cpp', '.c', '.h', 
    '.php', '.rb', '.go', '.swift', '.css', '.scss', '.less', '.js', '.ts', '.jsx', '.tsx', 
    '.json', '.yaml', '.sql', '.sqlite', '.db', '.md5', '.sha1', '.sha256', '.pem', '.pfx', 
    '.crt', '.cer', '.key', '.csr', '.pub', '.jks', '.der', '.p12', '.ini', '.conf', '.env', 
    '.properties', '.log', '.bak', '.swp', '.swo', '.tmp', '.dbf', '.db3', '.mdb', '.accdb'
}

handler = PathExtensionHandler(file_extensions)

ext = handler.analyze_file(file)
path = Path(file)
print(f"Extension(s): {ext}")
