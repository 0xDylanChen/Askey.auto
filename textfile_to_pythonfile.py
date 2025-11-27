import os

folder_path = r"C:\Users\dylan2_chen\Desktop\python_tool"

# 取得資料夾下所有的檔案名稱
for filename in os.listdir(folder_path):
    # 如果檔案名稱的結尾是 ".txt"，則將檔案名稱改為 ".py"
    if filename.endswith(".txt"):
        os.rename(os.path.join(folder_path, filename), os.path.join(folder_path, filename[:-4] + ".py"))