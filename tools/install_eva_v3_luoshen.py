"""Install the approved purple EVA archive as the only default build."""

from hashlib import sha256
import os
from pathlib import Path
import struct
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/source/eva_v2_luoshen/eva-v2-luoshen-purple.zip"
TARGET = ROOT / "anim/eva.zip"
SOURCE_SHA256 = "c540aed44a1bb70686a4692ebbd4bb68dc1aa7f361e87340a91e6cdf0c48a644"


def rename_build_identity(data: bytes, target_name: str) -> bytes:
    if data[:4] != b"BILD":
        raise ValueError("expected BILD")
    length = struct.unpack_from("<I", data, 16)[0]
    name = data[20:20 + length]
    if name != b"xd_luoshen":
        raise ValueError(f"unexpected source build {name!r}")
    encoded = target_name.encode("ascii")
    return data[:16] + struct.pack("<I", len(encoded)) + encoded + data[20 + length:]


def install_one(source: Path, target: Path, expected_sha256: str,
                build_name: str) -> str:
    source = Path(source)
    target = Path(target)
    digest = sha256(source.read_bytes()).hexdigest()
    if digest != expected_sha256:
        raise ValueError(f"candidate changed: {source}: {digest}")
    with ZipFile(source) as archive:
        rows = [(info, archive.read(info.filename)) for info in archive.infolist()]
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = target.with_name(target.name + ".eva.tmp")
    with ZipFile(temporary, "w") as output:
        for info, data in rows:
            output.writestr(
                info,
                rename_build_identity(data, build_name)
                if info.filename == "build.bin" else data,
            )
    os.replace(temporary, target)
    return sha256(target.read_bytes()).hexdigest()


def install() -> dict[str, str]:
    return {"eva": install_one(SOURCE, TARGET, SOURCE_SHA256, "eva")}


if __name__ == "__main__":
    print(install())
