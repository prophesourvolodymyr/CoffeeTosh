import json, struct
import base64
def get_glb_data(p):
    with open(p, 'rb') as f:
        f.read(12)
        chunk_len = struct.unpack('<I', f.read(4))[0]
        f.read(4)
        return json.loads(f.read(chunk_len).decode('utf-8'))
gltf = get_glb_data('WEBSITE 2/assets/macbook.glb')
for m in gltf.get('meshes', []):
    if 'VCQqxpxkUlzqcJI' in m.get('name', '') or 'lid' in m.get('name', '').lower() or 'screen' in m.get('name', '').lower():
        print(m.get('name'))
