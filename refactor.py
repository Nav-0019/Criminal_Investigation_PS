import os
import re

lib_dir = r"d:\Github\Criminal_Investigation_PS\frontend\lib"

# We want to remove `const` from `const Text(`, `const Icon(`, `const TextStyle(`, `const BorderSide(`, `const Border(`, `const EdgeInsets`, `const BoxDecoration` etc if they contain `AppColors` on the same line or within the same block.
# Actually, the easiest way to remove `const` safely is to just remove `const ` completely everywhere if it's right before something that uses AppColors. But multiline is hard.
# So, we will just globally remove `const ` if it appears before common widget classes that we know use AppColors.

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Simple approach: remove `const ` anywhere it is immediately before a Widget or class that might use AppColors.
    # This might remove some unnecessary consts, but Flutter performance hit is negligible for this project.
    
    # We'll just remove `const ` globally before things like `TextStyle`, `Icon`, `Text`, `BoxDecoration`, `Border`, `BorderSide`, `Row`, `Column`, `SizedBox`, `Padding`, `Container`, `Color`, `ColorFilter`
    
    classes_to_unconst = ['TextStyle', 'Icon', 'Text', 'BoxDecoration', 'Border', 'BorderSide', 'Row', 'Column', 'SizedBox', 'Padding', 'Container', 'Color', 'LinearGradient', 'Divider', 'Expanded', 'Center', 'ListView', 'Wrap']
    
    for c in classes_to_unconst:
        content = re.sub(r'\bconst\s+' + c + r'\b', c, content)

    # For lists: `const [` -> `[`
    content = content.replace('const [', '[')
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Done stripping consts.")
