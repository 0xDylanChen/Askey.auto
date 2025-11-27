import os
from docx2pdf import convert


try:
    from docx2pdf import convert
except ImportError:
    # 如果庫未被安裝，使用pip進行安裝
    os.system('pip install docx2pdf')
    from docx2pdf import convert

# 獲取當前目錄路徑
directory_path = os.getcwd()

# 循環遍歷目錄中的所有文件
for filename in os.listdir(directory_path):
    if filename.endswith(".docx"):
        # 確定新的PDF文件名
        pdf_filename = os.path.splitext(filename)[0] + ".pdf"
        pdf_filepath = os.path.join(directory_path, pdf_filename)

        # 如果PDF文件不存在，則轉換Word文件
        if not os.path.exists(pdf_filepath):
            docx_filepath = os.path.join(directory_path, filename)
            convert(docx_filepath, pdf_filepath)