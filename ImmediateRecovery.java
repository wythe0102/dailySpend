import java.io.*;
import java.sql.*;
import java.nio.file.*;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ImmediateRecovery {
    
    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("   MySQL数据紧急恢复检查工具");
        System.out.println("========================================");
        System.out.println("检查时间: " + new Date());
        System.out.println();
        
        try {
            // 1. 检查MySQL连接
            checkMySQLConnection();
            
            // 2. 检查当前数据状态
            checkDataStatus();
            
            // 3. 检查可能的恢复源
            checkRecoverySources();
            
            // 4. 创建紧急备份
            createEmergencyBackup();
            
            // 5. 生成恢复建议
            generateRecoveryAdvice();
            
        } catch (Exception e) {
            System.err.println("错误: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private static void checkMySQLConnection() {
        System.out.println("🔍 检查MySQL连接...");
        
        String[] urls = {
            "jdbc:mysql://localhost:3306/spend?useSSL=false&serverTimezone=UTC",
            "jdbc:mysql://localhost:3306/mysql?useSSL=false&serverTimezone=UTC"
        };
        
        for (String url : urls) {
            try (Connection conn = DriverManager.getConnection(url, "root", "root")) {
                System.out.println("✅ 成功连接到: " + url);
                
                // 检查数据库版本
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT VERSION()")) {
                    if (rs.next()) {
                        System.out.println("MySQL版本: " + rs.getString(1));
                    }
                }
                
                // 检查数据库列表
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SHOW DATABASES")) {
                    System.out.println("可用数据库:");
                    while (rs.next()) {
                        System.out.println("  - " + rs.getString(1));
                    }
                }
                
                break;
            } catch (SQLException e) {
                System.out.println("❌ 连接失败: " + e.getMessage());
            }
        }
        System.out.println();
    }
    
    private static void checkDataStatus() {
        System.out.println("🔍 检查数据状态...");
        
        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/spend?useSSL=false&serverTimezone=UTC", 
                "root", "root")) {
            
            // 检查表状态
            String[] tables = {"daily_spend", "users", "type"};
            
            for (String table : tables) {
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery(
                         "SELECT COUNT(*) as count FROM " + table)) {
                    if (rs.next()) {
                        int count = rs.getInt("count");
                        System.out.println(table + " 表记录数: " + count);
                        
                        // 如果是daily_spend，获取更多信息
                        if (table.equals("daily_spend") && count > 0) {
                            try (Statement stmt2 = conn.createStatement();
                                 ResultSet rs2 = stmt2.executeQuery(
                                     "SELECT MIN(date) as min_date, MAX(date) as max_date FROM daily_spend")) {
                                if (rs2.next()) {
                                    System.out.println("  最早记录: " + rs2.getString("min_date"));
                                    System.out.println("  最新记录: " + rs2.getString("max_date"));
                                }
                            }
                        }
                    }
                } catch (SQLException e) {
                    System.out.println("❌ 无法查询 " + table + ": " + e.getMessage());
                }
            }
            
            // 检查表结构信息
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(
                     "SELECT table_name, table_rows, data_length, create_time " +
                     "FROM information_schema.tables WHERE table_schema = 'spend'")) {
                System.out.println("\n表结构信息:");
                while (rs.next()) {
                    System.out.printf("  %-15s 记录: %-6d 大小: %-10s 创建: %s\n",
                        rs.getString("table_name"),
                        rs.getLong("table_rows"),
                        formatBytes(rs.getLong("data_length")),
                        rs.getString("create_time"));
                }
            }
            
        } catch (SQLException e) {
            System.out.println("❌ 数据库连接问题: " + e.getMessage());
        }
        System.out.println();
    }
    
    private static void checkRecoverySources() {
        System.out.println("🔍 检查恢复源...");
        
        // 检查MySQL数据目录
        String[] mysqlPaths = {
            "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data",
            "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Data",
            "C:\\xampp\\mysql\\data"
        };
        
        for (String path : mysqlPaths) {
            File dir = new File(path + "\\spend");
            if (dir.exists() && dir.isDirectory()) {
                System.out.println("✅ 找到MySQL数据目录: " + dir.getAbsolutePath());
                
                File[] files = dir.listFiles((dir1, name) -> 
                    name.toLowerCase().contains("daily_spend"));
                
                if (files != null && files.length > 0) {
                    System.out.println("  daily_spend相关文件:");
                    for (File file : files) {
                        System.out.printf("    %s - %s bytes - %s\n",
                            file.getName(), 
                            formatBytes(file.length()),
                            new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date(file.lastModified())));
                    }
                }
            }
        }
        
        // 检查本地SQL文件
        File currentDir = new File(".");
        checkDirectoryForSQL(currentDir, 2);
        
        System.out.println();
    }
    
    private static void checkDirectoryForSQL(File dir, int depth) {
        if (depth <= 0) return;
        
        File[] sqlFiles = dir.listFiles((dir1, name) -> name.toLowerCase().endsWith(".sql"));
        if (sqlFiles != null && sqlFiles.length > 0) {
            System.out.println("  找到SQL文件在: " + dir.getAbsolutePath());
            for (File file : sqlFiles) {
                System.out.printf("    %s - %s\n", file.getName(), formatBytes(file.length()));
            }
        }
        
        File[] subdirs = dir.listFiles(File::isDirectory);
        if (subdirs != null) {
            for (File subdir : subdirs) {
                if (!subdir.getName().startsWith(".") && !subdir.getName().equals("node_modules")) {
                    checkDirectoryForSQL(subdir, depth - 1);
                }
            }
        }
    }
    
    private static void createEmergencyBackup() {
        System.out.println("🔍 创建紧急备份...");
        
        String backupDir = "recovery-backup-" + new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date());
        File backup = new File(backupDir);
        if (!backup.exists()) {
            backup.mkdirs();
        }
        
        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/spend?useSSL=false&serverTimezone=UTC", 
                "root", "root")) {
            
            // 创建数据备份
            String[] tables = {"daily_spend", "users", "type", "budget", "daily_weight"};
            
            for (String table : tables) {
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT * FROM " + table)) {
                    
                    File backupFile = new File(backup, table + "-backup.csv");
                    try (PrintWriter writer = new PrintWriter(new FileWriter(backupFile))) {
                        
                        ResultSetMetaData meta = rs.getMetaData();
                        int columnCount = meta.getColumnCount();
                        
                        // 写入表头
                        for (int i = 1; i <= columnCount; i++) {
                            writer.print(meta.getColumnName(i));
                            if (i < columnCount) writer.print(",");
                        }
                        writer.println();
                        
                        // 写入数据
                        int rowCount = 0;
                        while (rs.next()) {
                            for (int i = 1; i <= columnCount; i++) {
                                String value = rs.getString(i);
                                if (value != null && value.contains(",")) {
                                    value = "\"" + value.replace("\"", "\"\"") + "\"";
                                }
                                writer.print(value != null ? value : "");
                                if (i < columnCount) writer.print(",");
                            }
                            writer.println();
                            rowCount++;
                        }
                        
                        System.out.println("  备份 " + table + " 表: " + rowCount + " 条记录 -> " + backupFile.getName());
                    }
                } catch (SQLException e) {
                    System.out.println("  跳过 " + table + " 表: " + e.getMessage());
                }
            }
            
            System.out.println("✅ 紧急备份完成: " + backup.getAbsolutePath());
            
        } catch (Exception e) {
            System.out.println("❌ 备份创建失败: " + e.getMessage());
        }
        System.out.println();
    }
    
    private static void generateRecoveryAdvice() {
        System.out.println("📋 恢复建议:");
        System.out.println();
        System.out.println("1. 立即检查二进制日志:");
        System.out.println("   mysql -uroot -proot -e \"SHOW BINARY LOGS;\"");
        System.out.println();
        System.out.println("2. 检查系统还原点:");
        System.out.println("   vssadmin list shadows /for=C:");
        System.out.println();
        System.out.println("3. 检查MySQL数据目录:");
        System.out.println("   C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\spend\\");
        System.out.println();
        System.out.println("4. 查找本地备份:");
        System.out.println("   查看 recovery-backup-* 目录中的备份文件");
        System.out.println();
        System.out.println("5. 如果以上无效，联系专业数据恢复服务");
    }
    
    private static String formatBytes(long bytes) {
        if (bytes < 1024) return bytes + " B";
        int exp = (int) (Math.log(bytes) / Math.log(1024));
        String pre = "KMGTPE".charAt(exp-1) + "";
        return String.format("%.1f %sB", bytes / Math.pow(1024, exp), pre);
    }
}