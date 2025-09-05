import java.sql.*;

public class CheckData {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/spend";
        String user = "root";
        String password = "password";
        
        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            System.out.println("成功连接到数据库！");
            
            // 检查daily_spend表数据量
            String countSql = "SELECT COUNT(*) as count FROM daily_spend";
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(countSql)) {
                if (rs.next()) {
                    System.out.println("daily_spend表数据条数: " + rs.getLong("count"));
                }
            }
            
            // 检查其他表
            String[] tables = {"daily_spend", "users", "type", "daily_weight", "budget"};
            for (String table : tables) {
                String sql = "SELECT COUNT(*) as count FROM " + table;
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery(sql)) {
                    if (rs.next()) {
                        System.out.println(table + "表数据条数: " + rs.getLong("count"));
                    }
                }
            }
            
            // 检查daily_spend表的最后几条数据
            System.out.println("\n--- daily_spend表最后5条数据 ---");
            String lastDataSql = "SELECT * FROM daily_spend ORDER BY spendDetailId DESC LIMIT 5";
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(lastDataSql)) {
                while (rs.next()) {
                    System.out.printf("ID: %d, 金额: %.2f, 日期: %s, 备注: %s%n",
                        rs.getLong("spendDetailId"),
                        rs.getBigDecimal("amount"),
                        rs.getDate("date"),
                        rs.getString("demo"));
                }
            }
            
        } catch (SQLException e) {
            System.out.println("数据库连接失败: " + e.getMessage());
            System.out.println("请确认:");
            System.out.println("1. MySQL服务是否正在运行");
            System.out.println("2. 数据库 'spend' 是否存在");
            System.out.println("3. 用户名密码是否正确");
        }
    }
}