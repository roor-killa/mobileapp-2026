import os

file_path = r'c:\Users\missf\Desktop\banqueEnLigne\mobileapp-2026\fatoubank\lib\screens\dashboard\dashboard_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
imported = False
added_fab = False

for line in lines:
    # Add import if not present
    if "import 'package:fatoubank/screens/dashboard/ai_assistant_screen.dart';" in line:
        imported = True
    
    # Identify where to add FAB (before the closing Scaffold paren)
    # We look for the last '    );' which is the Scaffold closing
    new_lines.append(line)

# Add import at top if missing
if not imported:
    new_lines.insert(1, "import 'package:fatoubank/screens/dashboard/ai_assistant_screen.dart';\n")

# Find the Scaffold closing (last ); before empty lines/end)
target_index = -1
for i in range(len(new_lines) - 1, 0, -1):
    if ");" in new_lines[i] and i > 200: # Scaffold is near the end
        target_index = i
        break

if target_index != -1:
    fab_code = [
        "      floatingActionButton: FloatingActionButton(\n",
        "        onPressed: () {\n",
        "          Navigator.push(context, MaterialPageRoute(builder: (_) => const AIAssistantScreen()));\n",
        "        },\n",
        "        backgroundColor: AppColors.primary,\n",
        "        elevation: 8,\n",
        "        child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 28),\n",
        "      ),\n"
    ]
    # Insert before the );
    new_lines.insert(target_index, "".join(fab_code))
    added_fab = True

if added_fab:
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print("Successfully updated DashboardScreen with AI Assistant FAB.")
else:
    print("Could not find insertion point for FAB.")
