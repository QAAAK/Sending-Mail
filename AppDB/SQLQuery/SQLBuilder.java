package SQLQuery;

import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import java.awt.*;
import java.io.FileNotFoundException;
import java.io.UnsupportedEncodingException;
import java.sql.*;
import java.io.PrintWriter;

public class SQLBuilder extends Component {

    public static Connection connect() {


        try {
            String url = "jdbc:sqlite:C:\\Users\\santalovdv\\Desktop\\Java\\sample-database-sqlite-1\\Chinook.db";

            Connection conn = DriverManager.getConnection(url);

            System.out.println("Подключение произошло успешно.");

            return conn;

        } catch (SQLException e) {

            System.out.println("Ошибка при подключении");
            System.out.println(e.getMessage());


            return (Connection) e;

        }
    }

    public static String refactoringColumns(String columns) {

        return columns.substring(0, columns.length() - 1);

    }


    public String PathFile() {
        JFileChooser fileChooser = new JFileChooser();

        fileChooser.setDialogTitle("Выберите место сохранения файла");
        fileChooser.setFileFilter(new FileNameExtensionFilter("CSV files (*.csv)", "csv"));

        int userSelection = fileChooser.showSaveDialog(this);

        if (userSelection == JFileChooser.APPROVE_OPTION) {
            String filePath = fileChooser.getSelectedFile().getAbsolutePath();

            if (!filePath.toLowerCase().endsWith(".csv")) {
                filePath += ".csv";
            }
            return filePath;
        }
        return null;
    }


    public static void queryToCSV(String query, Connection conn, String filePath) throws SQLException, FileNotFoundException, UnsupportedEncodingException {

        Statement stmt = conn.createStatement();
        ResultSet result = stmt.executeQuery(query);
        ResultSetMetaData metaData = result.getMetaData();

        int columnsNumber = metaData.getColumnCount();
        PrintWriter writer = new PrintWriter(filePath);

        for (int i = 1; i <= columnsNumber; i++) {
            writer.print(metaData.getColumnName(i)); // Записываем наименования колонок
            if (i < columnsNumber) {
                writer.print(",");
            }
        }
        writer.println();

        while (result.next()) {
            for (int i = 1; i <= columnsNumber; i++) {
                writer.print(result.getString(i));
                if (i < columnsNumber) {
                    writer.print(",");
                }
            }
            writer.println();
        }
        writer.close();
    }


    public static void about ()  {

        JFrame jFrame = new JFrame();
        JOptionPane.showMessageDialog(jFrame, "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt\n" +
                " ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut\n" +
                " aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore\n " +
                "eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt\n " +
                "mollit anim id est laborum.\n ");
    }


    public static void saveMessage () {

        JFrame jFrame = new JFrame();
        JOptionPane.showMessageDialog(jFrame, "Сохранение завершено. Пожалуйста, закройте приложение.");

    }


}
