import os
import subprocess
import datetime
import re

def run_mysql_command(command):
    """运行MySQL命令"""
    mysql_path = r"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
    cmd = f'"{mysql_path}" -h localhost -u root -ppassword -e "{command}"'
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout, result.stderr
    except Exception as e:
        return "", str(e)

def run_mysqlbinlog_command(log_file, start_time, end_time):
    """运行mysqlbinlog命令"""
    mysqlbinlog_path = r"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqlbinlog.exe"
    cmd = f'"{mysqlbinlog_path}" --start-datetime="{start_time}" --stop-datetime="{end_time}" "{log_file}"'
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout, result.stderr
    except Exception as e:
        return "", str(e)

def main():
    print("🚨 紧急数据恢复 - 二进制日志分析")
    print("=" * 50)
    
    # 1. 检查当前数据状态
    print("\n1. 当前数据状态:")
    stdout, stderr = run_mysql_command("USE spend; SELECT COUNT(*) as daily_spend_count FROM daily_spend;")
    if stdout:
        lines = stdout.strip().split('\n')
        if len(lines) >= 2:
            count = lines[1].strip()
            print(f"   daily_spend表记录数: {count}")
    
    # 2. 查找二进制日志
    print("\n2. 查找二进制日志文件...")
    data_dir = r"C:\ProgramData\MySQL\MySQL Server 8.0\Data"
    
    binlog_files = []
    for file in os.listdir(data_dir):
        if file.startswith("WYTHE-DESKTOP-bin.") and file.endswith(('.000911', '.000912', '.000913', '.000914', '.000915')):
            binlog_files.append(os.path.join(data_dir, file))
    
    binlog_files.sort()
    print(f"   找到 {len(binlog_files)} 个日志文件")
    
    # 3. 分析每个日志文件
    print("\n3. 分析日志文件中的INSERT操作...")
    
    recovery_sql = []
    recovery_sql.append("-- 从二进制日志恢复的daily_spend数据")
    recovery_sql.append("-- 恢复时间: " + str(datetime.datetime.now()))
    recovery_sql.append("")
    
    total_inserts = 0
    
    for log_file in binlog_files:
        print(f"   分析: {os.path.basename(log_file)}")
        
        # 分析2024-08-25到2024-08-26的日志
        stdout, stderr = run_mysqlbinlog_command(log_file, "2024-08-25 00:00:00", "2024-08-26 23:59:59")
        
        if stdout:
            # 查找INSERT INTO daily_spend语句
            lines = stdout.split('\n')
            for line in lines:
                if 'INSERT INTO `daily_spend`' in line or 'INSERT INTO daily_spend' in line:
                    # 提取完整的INSERT语句
                    insert_match = re.search(r'INSERT INTO.*?(?=;)', line, re.IGNORECASE | re.DOTALL)
                    if insert_match:
                        recovery_sql.append(insert_match.group(0) + ";")
                        total_inserts += 1
    
    print(f"\n   找到 {total_inserts} 条INSERT语句")
    
    # 4. 保存恢复SQL
    if total_inserts > 0:
        recovery_file = "recovery_daily_spend.sql"
        with open(recovery_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(recovery_sql))
        
        print(f"\n4. 恢复SQL已保存到: {recovery_file}")
        print(f"   文件大小: {os.path.getsize(recovery_file)} 字节")
        
        # 5. 执行恢复
        print("\n5. 执行恢复...")
        
        # 先备份当前数据
        backup_sql = f"CREATE TABLE daily_spend_backup_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')} LIKE daily_spend; INSERT INTO daily_spend_backup_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')} SELECT * FROM daily_spend;"
        run_mysql_command(backup_sql)
        
        # 执行恢复
        with open(recovery_file, 'r', encoding='utf-8') as f:
            recovery_content = f.read()
        
        # 分批执行恢复语句
        statements = [s.strip() for s in recovery_sql if s.strip() and not s.startswith('--')]
        
        success_count = 0
        for statement in statements:
            if statement.startswith('INSERT'):
                stdout, stderr = run_mysql_command(f"USE spend; {statement}")
                if not stderr or "ERROR" not in stderr:
                    success_count += 1
        
        print(f"   成功执行 {success_count} 条恢复语句")
        
        # 6. 验证恢复结果
        print("\n6. 验证恢复结果:")
        stdout, stderr = run_mysql_command("USE spend; SELECT COUNT(*) as 恢复后记录数 FROM daily_spend;")
        if stdout:
            lines = stdout.strip().split('\n')
            if len(lines) >= 2:
                count = lines[1].strip()
                print(f"   恢复后daily_spend表记录数: {count}")
    
    else:
        print("\n4. 未找到可恢复的INSERT语句")
        print("   建议检查:")
        print("   - 更早的日志文件")
        print("   - 其他表名")
        print("   - 系统还原点")

if __name__ == "__main__":
    main()
    input("\n按Enter键继续...")