import os
import subprocess
import datetime
import json
import shutil

def run_command(cmd):
    """运行命令并返回结果"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout, result.stderr, result.returncode
    except Exception as e:
        return "", str(e), 1

def check_mysql_connection():
    """检查MySQL连接"""
    print("🔍 检查MySQL连接...")
    cmd = '"C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin\\mysql.exe" -h localhost -u root -ppassword -e "SELECT 1;"'
    stdout, stderr, code = run_command(cmd)
    return code == 0

def get_current_data():
    """获取当前数据状态"""
    print("📊 获取当前数据状态...")
    cmd = '"C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin\\mysql.exe" -h localhost -u root -ppassword -e "USE spend; SELECT table_name, table_rows FROM information_schema.tables WHERE table_schema = \"spend\";"'
    stdout, stderr, code = run_command(cmd)
    if code == 0:
        lines = stdout.strip().split('\n')[1:]  # 跳过标题行
        data = {}
        for line in lines:
            if line.strip():
                parts = line.split('\t')
                if len(parts) >= 2:
                    table_name = parts[0]
                    try:
                        row_count = int(parts[1])
                        data[table_name] = row_count
                    except ValueError:
                        data[table_name] = 0
        return data
    return {}

def analyze_binlogs():
    """分析二进制日志"""
    print("🔍 分析二进制日志...")
    
    data_dir = "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data"
    binlog_path = "C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin\\mysqlbinlog.exe"
    
    # 获取所有二进制日志文件
    binlog_files = []
    for file in os.listdir(data_dir):
        if file.startswith("WYTHE-DESKTOP-bin."):
            binlog_files.append(os.path.join(data_dir, file))
    
    binlog_files.sort()
    
    recovery_data = []
    
    print(f"   找到 {len(binlog_files)} 个二进制日志文件")
    
    # 分析每个日志文件
    for log_file in binlog_files[-10:]:  # 只分析最近的10个文件
        print(f"   分析 {os.path.basename(log_file)}...")
        
        # 检查文件大小
        file_size = os.path.getsize(log_file)
        if file_size < 1000:  # 跳过太小的文件
            continue
            
        # 提取日志内容
        cmd = f'"{binlog_path}" "{log_file}"'
        stdout, stderr, code = run_command(cmd)
        
        if code == 0:
            # 查找daily_spend相关操作
            lines = stdout.split('\n')
            
            # 查找INSERT操作
            insert_count = 0
            delete_count = 0
            
            for line in lines:
                if 'INSERT INTO `daily_spend`' in line:
                    insert_count += 1
                elif 'DELETE FROM `daily_spend`' in line:
                    delete_count += 1
            
            if insert_count > 0 or delete_count > 0:
                recovery_data.append({
                    'file': os.path.basename(log_file),
                    'size': file_size,
                    'inserts': insert_count,
                    'deletes': delete_count
                })
    
    return recovery_data

def check_system_restore_points():
    """检查系统还原点"""
    print("🔍 检查系统还原点...")
    cmd = 'vssadmin list shadows /for=C:'
    stdout, stderr, code = run_command(cmd)
    
    if code == 0:
        # 解析卷影复制信息
        lines = stdout.split('\n')
        restore_points = []
        
        for line in lines:
            if 'Creation Time:' in line:
                time_str = line.split('Creation Time:')[1].strip()
                restore_points.append(time_str)
        
        return restore_points
    return []

def check_backup_files():
    """检查备份文件"""
    print("🔍 检查备份文件...")
    
    backup_extensions = ['.sql', '.bak', '.dump', '.backup']
    backup_files = []
    
    # 检查常见备份目录
    check_dirs = [
        'C:\\',
        'D:\\',
        os.path.expanduser('~'),
        'C:\\Users',
        'D:\\backup',
        'D:\\backups'
    ]
    
    for check_dir in check_dirs:
        if os.path.exists(check_dir):
            for root, dirs, files in os.walk(check_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    if any(file.lower().endswith(ext) for ext in backup_extensions):
                        if 'spend' in file.lower() or 'daily' in file.lower():
                            try:
                                size = os.path.getsize(file_path)
                                mod_time = datetime.datetime.fromtimestamp(os.path.getmtime(file_path))
                                backup_files.append({
                                    'path': file_path,
                                    'size': size,
                                    'modified': str(mod_time)
                                })
                            except:
                                pass
    
    return backup_files

def create_recovery_report():
    """创建恢复报告"""
    print("📋 创建恢复报告...")
    
    report = {
        'timestamp': str(datetime.datetime.now()),
        'mysql_connection': False,
        'current_data': {},
        'binlog_analysis': [],
        'restore_points': [],
        'backup_files': [],
        'recommendations': []
    }
    
    # 检查MySQL连接
    report['mysql_connection'] = check_mysql_connection()
    
    if report['mysql_connection']:
        # 获取当前数据
        report['current_data'] = get_current_data()
        
        # 分析二进制日志
        report['binlog_analysis'] = analyze_binlogs()
    
    # 检查系统还原点
    report['restore_points'] = check_system_restore_points()
    
    # 检查备份文件
    report['backup_files'] = check_backup_files()
    
    # 生成建议
    recommendations = []
    
    if report['current_data'].get('daily_spend', 0) < 1000:
        recommendations.append("daily_spend表记录数异常少，建议恢复")
    
    if report['binlog_analysis']:
        for log in report['binlog_analysis']:
            if log['inserts'] > 100:
                recommendations.append(f"日志文件 {log['file']} 包含 {log['inserts']} 条插入操作，可恢复")
    
    if report['backup_files']:
        for backup in report['backup_files']:
            if backup['size'] > 10000:  # 大于10KB
                recommendations.append(f"找到备份文件: {backup['path']} ({backup['size']} bytes)")
    
    if report['restore_points']:
        recommendations.append(f"找到 {len(report['restore_points'])} 个系统还原点")
    
    report['recommendations'] = recommendations
    
    # 保存报告
    with open('recovery_report.json', 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    
    return report

def generate_recovery_sql():
    """生成恢复SQL"""
    print("🔧 生成恢复SQL...")
    
    # 检查是否有二进制日志包含大量数据
    data_dir = "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data"
    binlog_path = "C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin\\mysqlbinlog.exe"
    
    # 查找最大的日志文件
    binlog_files = []
    for file in os.listdir(data_dir):
        if file.startswith("WYTHE-DESKTOP-bin."):
            file_path = os.path.join(data_dir, file)
            size = os.path.getsize(file_path)
            binlog_files.append((file_path, size))
    
    binlog_files.sort(key=lambda x: x[1], reverse=True)
    
    if binlog_files:
        largest_log = binlog_files[0][0]
        print(f"   分析最大的日志文件: {os.path.basename(largest_log)}")
        
        # 提取日志内容
        cmd = f'"{binlog_path}" "{largest_log}"'
        stdout, stderr, code = run_command(cmd)
        
        if code == 0:
            # 保存完整日志用于手动分析
            with open('full_binlog_analysis.txt', 'w', encoding='utf-8') as f:
                f.write(stdout)
            
            print("   完整日志已保存到: full_binlog_analysis.txt")
            print("   请手动检查此文件以找到可恢复的INSERT语句")

def main():
    print("🚨 最终数据恢复工具")
    print("=" * 50)
    
    # 创建恢复报告
    report = create_recovery_report()
    
    print("\n" + "=" * 50)
    print("📊 恢复报告摘要:")
    print("=" * 50)
    
    print(f"MySQL连接: {'✅ 正常' if report['mysql_connection'] else '❌ 失败'}")
    
    if report['current_data']:
        print("\n当前数据状态:")
        for table, count in report['current_data'].items():
            print(f"  {table}: {count} 条记录")
    
    if report['binlog_analysis']:
        print("\n二进制日志分析:")
        for log in report['binlog_analysis']:
            print(f"  {log['file']}: {log['inserts']} 插入, {log['deletes']} 删除")
    
    if report['backup_files']:
        print("\n备份文件:")
        for backup in report['backup_files'][:5]:  # 只显示前5个
            print(f"  {backup['path']} ({backup['size']} bytes)")
    
    if report['restore_points']:
        print(f"\n系统还原点: {len(report['restore_points'])} 个")
    
    print("\n📋 恢复建议:")
    for i, rec in enumerate(report['recommendations'], 1):
        print(f"  {i}. {rec}")
    
    # 生成恢复SQL
    generate_recovery_sql()
    
    print("\n" + "=" * 50)
    print("🔧 下一步行动:")
    print("1. 检查 recovery_report.json 获取详细信息")
    print("2. 查看 full_binlog_analysis.txt 寻找可恢复的SQL")
    print("3. 检查系统还原点 (vssadmin list shadows)")
    print("4. 手动检查备份文件")
    print("5. 考虑使用专业数据恢复工具")

if __name__ == "__main__":
    main()
    input("\n按Enter键继续...")