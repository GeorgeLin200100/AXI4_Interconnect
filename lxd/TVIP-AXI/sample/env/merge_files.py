import sys
import os
import glob

def merge_files(output_filename="merged_output.txt"):
    if len(sys.argv) < 2:
        print("请提供至少一个文件名或通配符模式作为参数。")
        return

    patterns = sys.argv[1:]

    # 展开所有通配符，获取匹配的文件名
    input_files = []
    for pattern in patterns:
        matches = glob.glob(pattern)
        if not matches:
            print(f"⚠️ 没有找到匹配 '{pattern}' 的文件。")
        else:
            input_files.extend(matches)

    if not input_files:
        print("❌ 没有任何文件可以合并。")
        return

    # 排序以保持一致性（可选）
    input_files = sorted(input_files)

    try:
        with open(output_filename, 'w', encoding='utf-8') as outfile:
            for filename in input_files:
                if not os.path.isfile(filename):
                    print(f"跳过无效文件: {filename}")
                    continue
                with open(filename, 'r', encoding='utf-8') as infile:
                    content = infile.read()
                    outfile.write(f"=== 开始文件: {filename} ===\n")
                    outfile.write(content)
                    outfile.write(f"\n=== 结束文件: {filename} ===\n\n\n")
        print(f"✅ 合并完成，输出文件为: {output_filename}")
        print(f"📄 已合并以下文件:\n" + "\n".join(f" - {f}" for f in input_files))
    except Exception as e:
        print(f"❌ 写入文件时发生错误: {e}")

if __name__ == "__main__":
    merge_files()