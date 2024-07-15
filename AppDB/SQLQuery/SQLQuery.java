package SQLQuery;


import javax.swing.*;
import java.sql.*;

public class SQLQuery {

    private String tableName;
    private String columnName = "";
    private String query = "";
    private String groupBy = "";
    private String orderBy = "";
    private String columnNameOrder = "";



    public String getTableName () {

        return tableName;

    }

    public void setTableName (String tableName) {

        this.tableName = tableName;

    }


    public String getColumnName () {

        return SQLBuilder.refactoringColumns(columnName);

    }

    public void setColumnName (String columnName) {

        this.columnName += columnName + ",";

    }



    public void setGroupBy (boolean variable) {

            if (variable == true) {
                this.groupBy = " GROUP BY " + SQLBuilder.refactoringColumns(this.columnName);

            }


    }

    public String getGroupBy () {

        return this.groupBy;

    }

    public void setColumnNameOrder (String columnName) {

        this.columnNameOrder += columnName + ",";

    }

    public void setOrderBy (boolean variable) {


        if (variable == true) {

            this.orderBy = " ORDER BY " + SQLBuilder.refactoringColumns(this.columnNameOrder);

        }

    }

    public String getOrderBy () {

        return this.orderBy;

    }

    public void setAgainData () {

        this.query = "";
        this.tableName = "";
        this.columnName = "";
        this.columnNameOrder = "";
        this.orderBy = "";
        this.groupBy = "";

    }


    public String executeQuery () {


        query = "SELECT " + getColumnName() + " FROM " + getTableName() + getGroupBy() + getOrderBy();

        return query;

    }

    public int countRow (Connection conn) throws SQLException {


        Statement stmt = conn.createStatement();
        ResultSet result = stmt.executeQuery("SELECT COUNT(*) FROM " + this.tableName);

        result.next();

        int count = result.getInt(1);


        JFrame jFrame = new JFrame();
        JOptionPane.showMessageDialog(jFrame, "Количество строк в таблице: " + String.valueOf(count));

        return count;
    }


//    public void about ()  {
//
//        JFrame jFrame = new JFrame();
//        JOptionPane.showMessageDialog(jFrame, "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt\n" +
//                                                " ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut\n" +
//                                                " aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore\n " +
//                                                "eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt\n " +
//                                                "mollit anim id est laborum.\n ");
//    }








}
