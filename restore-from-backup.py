import os
import subprocess
import shutil

def restore_from_backup():
    """从发现的备份文件恢复数据"""
    
    backup_file = r"C:\Users\wythe\Documents\dumps\Spend20220313.sql"
    
    if not os.path.exists(backup_file):
        print("❌ 备份文件不存在")
        return False
    
    print("🚨 开始从备份文件恢复数据...")
    print(f"备份文件: {backup_file}")
    print(f"文件大小: {os.path.getsize(backup_file)} bytes")
    
    # 创建临时文件处理编码问题
    temp_file = "temp_restore.sql"
    
    try:
        # 读取原始文件并处理编码
        with open(backup_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # 修复可能的编码问题
        content = content.replace('??????', '购物').replace('????', '其他')
        
        # 保存处理后的文件
        with open(temp_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print("✅ 备份文件编码处理完成")
        
        # 备份当前数据
        print("🔒 备份当前数据...")
        backup_cmd = f'"C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin\\mysqldump.exe" -h localhost -u root -ppassword spend > current_backup_{subprocess.check_output("date /t", shell=True).decode().strip().replace("/", "")}.sql'
        subprocess.run(backup_cmd, shell=True, capture_output=True)
        
        # 清空当前表
        print("🧹 清空当前表...")
        clear_cmd = f'"C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin\\mysql.exe" -h localhost -u root -ppassword -e "USE spend; SET FOREIGN_KEY_CHECKS = 0; TRUNCATE TABLE daily_spend; TRUNCATE TABLE users; TRUNCATE TABLE type; SET FOREIGN_KEY_CHECKS = 1;"'
        result = subprocess.run(clear_cmd, shell=True, capture_output=True, text=True)
        
        if result.returncode != 0:
            print(f"⚠️ 清空表时出错: {result.stderr}")
            return False
        
        # 执行恢复
        print("🔄 执行恢复...")
        restore_cmd = f'"C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin\\mysql.exe" -h localhost -u root -ppassword spend < "{temp_file}"'
        result = subprocess.run(restore_cmd, shell=True, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ 恢复成功！")
            
            # 验证恢复结果
            verify_cmd = f'"C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin\\mysql.exe" -h localhost -u root -ppassword -e "USE spend; SELECT COUNT(*) as daily_spend_count FROM daily_spend; SELECT COUNT(*) as users_count FROM users; SELECT COUNT(*) as type_count FROM type;"'
            verify_result = subprocess.run(verify_cmd, shell=True, capture_output=True, text=True)
            
            if verify_result.returncode == 0:
                print("\n📊 恢复后数据状态:")
                lines = verify_result.stdout.strip().split('\n')
                for line in lines[1:]:  # 跳过标题
                    if line.strip():
                        print(f"  {line}")
            
            return True
        else:
            print(f"❌ 恢复失败: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ 恢复过程中出错: {e}")
        return False
    finally:
        # 清理临时文件
        if os.path.exists(temp_file):
            os.remove(temp_file)

def manual_restore_guide():
    """提供手动恢复指导"""
    print("\n📋 手动恢复指导:")
    print("1. 打开MySQL命令行:")
    print('   mysql -u root -ppassword')
    print("2. 选择数据库:")
    print('   USE spend;')
    print("3. 查看当前数据:")
    print('   SELECT COUNT(*) FROM daily_spend;')
    print("4. 如果需要清空表:")
    print('   TRUNCATE TABLE daily_spend;')
    print('   TRUNCATE TABLE users;')
    print('   TRUNCATE TABLE type;')
    print("5. 从备份文件恢复:")
    print('   SOURCE C:\\Users\\wythe\\Documents\\dumps\\Spend20220313.sql;')
    print("6. 验证恢复:")
    print('   SELECT COUNT(*) FROM daily_spend;')

def main():
    print("🚨 数据恢复工具")
    print("=" * 40)
    
    # 检查当前数据
    print("📊 当前数据状态:")
    cmd = f'"C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin\\mysql.exe" -h localhost -u root -ppassword -e "USE spend; SELECT table_name, table_rows FROM information_schema.tables WHERE table_schema = \"spend\";"'
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    
    if result.returncode == 0:
        print(result.stdout)
    
    print("\n🔍 发现备份文件:")
    backup_file = r"C:\Users\wythe\Documents\dumps\Spend20220313.sql"
    if os.path.exists(backup_file):
        print(f"  ✅ {backup_file} ({os.path.getsize(backup_file)} bytes)")
        
        choice = input("\n是否开始恢复？(y/n): ").lower()
        if choice == 'y':
            success = restore_from_backup()
            if success:
                print("\n🎉 数据恢复完成！")
            else:
                print("\n⚠️ 自动恢复失败，请尝试手动恢复")
                manual_restore_guide()
        else:
            manual_restore_guide()
    else:
        print("❌ 未找到备份文件")
        manual_restore_guide()

if __name__ == "__main__":
    main()
    input("\n按Enter键退出...")