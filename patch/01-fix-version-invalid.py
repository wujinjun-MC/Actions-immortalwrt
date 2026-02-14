import re
import os
import argparse

# 匹配 PKG_VERSION 和 PKG_RELEASE 的正则 (支持 :=, =, ?=)
PKG_VER_RE = re.compile(r'^(PKG_VERSION\s*[:?]?=\s*)(.*)$')
PKG_REL_RE = re.compile(r'^(PKG_RELEASE\s*[:?]?=\s*)(.*)$')

def is_variable(val):
    """检测是否为 Makefile 变量，例如 ~~$(AUTO_RELEASE) 或~~ ${VERSION}"""
    return '$(' in val or '${' in val
    # return "$" in val

def sanitize_apk_version(version):
    """
    APK 版本合规化逻辑：
    1. 移除开头的 'v'。
    2. 按 [-. _] 分段。
    3. 数字开头 -> 提数字；字母开头 -> 归零。
    """
    val = version.strip()
    if not val or is_variable(val):
        return val

    # 移除开头的 v (符合 APK 必须以数字开头的强制要求)
    val = re.sub(r'^[vV]+', '', val)
    
    # 按照连接符拆分
    parts = re.split(r'[-._]', val)
    clean_parts = []
    
    for p in parts:
        if not p: continue
        
        if p[0].isdigit() or p[0] == "r":
            # 数字开头段：保留数字
            num = re.sub(r'\D', '', p)
            clean_parts.append(num if num else "0")
        else:
            # 字母开头段：整段变 0
            clean_parts.append("0")

    return ".".join(clean_parts) if clean_parts else "0"

def process_file(filepath, apply_changes=False):
    if not os.path.isfile(filepath):
        print(f"!! 找不到文件: {filepath}")
        return

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.splitlines()

        is_luci = any("luci.mk" in line for line in lines)
        new_lines = []
        file_changed = False
        
        for line in lines:
            # 处理 PKG_VERSION
            v_match = PKG_VER_RE.match(line)
            if v_match:
                prefix, old_val = v_match.groups()
                new_val = sanitize_apk_version(old_val)
                if old_val.strip() != new_val:
                    print(f"[VERSION] {filepath}: '{old_val.strip()}' -> '{new_val}'")
                    line = f"{prefix}{new_val}"
                    file_changed = True
            
            # 处理 PKG_RELEASE
            r_match = PKG_REL_RE.match(line)
            if r_match:
                prefix, old_val = r_match.groups()
                old_val_s = old_val.strip()
                
                # if is_luci:
                #     # LuCI 包强制清空
                #     if old_val_s != "":
                #         print(f"[LUCI-REL] {filepath}: 强制清空")
                #         line = "PKG_RELEASE:="
                #         file_changed = True
                # elif is_variable(old_val_s):
                #     # 非 LuCI 但包含变量引用 (如 $(ARCH)-1)，在 APK 中非法，强制重置为 1
                #     print(f"[DANGER-REL] {filepath}: 检测到变量污染 '{old_val_s}' -> '1'")
                #     line = "PKG_RELEASE:=1"
                #     file_changed = True
                # elif old_val_s:
                #     # 普通字符串执行合规化
                #     new_val = sanitize_apk_version(old_val_s)
                #     if old_val_s != new_val:
                #         print(f"[RELEASE] {filepath}: '{old_val_s}' -> '{new_val}'")
                #         line = f"{prefix}{new_val}"
                #         file_changed = True
                if '$(AUTORELEASE)' == old_val_s or '$(COMMITCOUNT)' == old_val_s:
                    print(f"[GOOD-REL-VAR] {filepath}: 安全的PKG_RELEASE '{old_val_s}'")
                    new_val = old_val_s
                elif is_variable(old_val_s):
                    # 非 LuCI 但包含变量引用 (如 $(ARCH)-1)，在 APK 中非法，强制重置为 1
                    print(f"[DANGER-REL] {filepath}: 检测到变量污染 '{old_val_s}' -> '1'")
                    line = "PKG_RELEASE:=1"
                    file_changed = True
                elif old_val_s:
                    # 普通字符串执行合规化
                    new_val = sanitize_apk_version(old_val_s).replace('.','')
                    if old_val_s != new_val:
                        print(f"[RELEASE] {filepath}: '{old_val_s}' -> '{new_val}'")
                        line = f"{prefix}{new_val}"
                        file_changed = True
            
            new_lines.append(line)

        if file_changed:
            if apply_changes:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write("\n".join(new_lines) + "\n")
                print(f"已写入文件: {filepath}")
            else:
                pass
                #print(f"[DRY-RUN] 建议修改上述内容 (使用 --apply 执行修改)")
        
        return file_changed

    except Exception as e:
        print(f"处理失败 {filepath}: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description="OpenWrt APK Version Fixer")
    parser.add_argument("direct_val", nargs='?', help="直接检查特定版本号")
    parser.add_argument("--file", help="检查并修复单个 Makefile")
    parser.add_argument("--files", nargs='+', help="检查并修复多个 Makefile")
    parser.add_argument("--dir", help="递归检查目录")
    parser.add_argument("--dirs", nargs='+', help="递归检查多个目录")
    parser.add_argument("--apply", action="store_true", help="显式确认执行修改 (默认仅预览)")

    args = parser.parse_args()

    # 1. 直接检查字符串
    if args.direct_val and not any([args.file, args.files, args.dir, args.dirs]):
        print(f"输入: {args.direct_val}")
        print(f"修复: {sanitize_apk_version(args.direct_val)}")
        return

    # 汇总待处理文件
    targets = []
    if args.file: targets.append(args.file)
    if args.files: targets.extend(args.files)
    
    # 汇总待处理目录
    tdirs = []
    if args.dir: tdirs.append(args.dir)
    if args.dirs: tdirs.extend(args.dirs)

    for d in tdirs:
        for root, _, files in os.walk(d):
            if "Makefile" in files:
                targets.append(os.path.join(root, "Makefile"))

    if not targets:
        print("提示: 未指定文件或目录。使用 -h 查看帮助。")
        return

    # 执行处理
    changed_count = 0
    for t in targets:
        if process_file(t, args.apply):
            changed_count += 1

    if not args.apply and changed_count > 0:
        print(f"\n总计发现 {changed_count} 个文件需要修正。请添加 --apply 参数执行实际修改。")

if __name__ == "__main__":
    main()