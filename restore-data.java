import java.sql.*;
import java.io.*;
import java.time.LocalDate;
import java.math.BigDecimal;
import java.util.Random;

public class RestoreData {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/spend";
        String user = "root";
        String password = "password";
        
        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            System.out.println("成功连接到数据库！");
            
            // 1. 先检查现有数据
            checkExistingData(conn);
            
            // 2. 如果数据很少，询问是否生成测试数据
            System.out.println("\n数据检查完成！");
            System.out.println("如果发现您的原始数据还在，可以：");
            System.out.println("1. 停止当前应用");
            System.out.println("2. 修改配置使用validate模式");
            System.out.println("3. 重新启动应用");
            
        } catch (SQLException e) {
            System.out.println("数据库连接失败: " + e.getMessage());
            System.out.println("\n可能的原因：");
            System.out.println("1. MySQL服务未启动");
            System.out.println("2. 数据库 'spend' 不存在");
            System.out.println("3. 用户名或密码错误");
            System.out.println("4. MySQL端口不是3306");
            
            System.out.println("\n解决方案：");
            System.out.println("1. 启动MySQL服务");
            System.out.println("2. 检查数据库是否存在");
            System.out.println("3. 确认连接信息");
        }
    }
    
    private static void checkExistingData(Connection conn) throws SQLException {
        String[] tables = {"daily_spend", "users", "type", "daily_weight", "budget"};
        
        for (String table : tables) {
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM " + table)) {
                if (rs.next()) {
                    long count = rs.getLong("count");
                    System.out.println(table + "表: " + count + " 条记录");
                    
                    // 如果是daily_spend表且数据很少
                    if (table.equals("daily_spend") && count < 100) {
                        System.out.println("⚠️ daily_spend表数据较少，可能需要恢复");
                    } else if (table.equals("daily_spend") && count >= 1000) {
                        System.out.println("✅ daily_spend表有大量数据，可能包含您的原始数据");
                    }
                }
            } catch (SQLException e) {
                System.out.println("表 " + table + " 不存在或无法访问");
            }
        }
    }
}