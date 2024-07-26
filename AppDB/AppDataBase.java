import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.FileNotFoundException;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.util.ArrayList;
import SQLQuery.*;

import java.sql.Connection;

public class AppDataBase extends JFrame {
    private final JTextField textFieldTable;
    private final JTextField textFieldColumn;
    private final JTextField textFieldGroup;
    private final JTextField textFieldOrder;

    private final Connection conn = SQLBuilder.connect();
    private final SQLBuilder saveFile = new SQLBuilder();
    private final JComboBox<String> comboBox; // Store the table combo box
    private final JComboBox<String> columnsComboBox;
    private final JComboBox<String> columnsOrderComboBox;
    private final JButton buttonSave;
    private final JButton buttonGroup;
    private final JButton buttonAgain;
    private final JButton buttonCountRow;
    private final JButton buttonAbout;

    public AppDataBase() throws SQLException {

        super("App DataBase");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        ImageIcon icon = new ImageIcon(getClass().getResource("logo.png"));
        setIconImage(icon.getImage());

        JPanel panel = new JPanel();

        SQLQuery sqlQuery = new SQLQuery();

        textFieldTable = new JTextField(90);
        textFieldTable.setText("Выбрать из таблицы:  ");
        panel.add(textFieldTable);

        textFieldColumn = new JTextField(90);
        textFieldColumn.setText("Выбрать поля : ");
        panel.add(textFieldColumn);

        textFieldGroup = new JTextField(90);
        textFieldGroup.setText("Группировать по : ");
        panel.add(textFieldGroup);

        textFieldOrder = new JTextField(90);
        textFieldOrder.setText("Сортировать по : ");
        panel.add(textFieldOrder);


        ArrayList<String> tableNameAsDB = SQLMetaData.allNamesTables(conn);
        String[] tableNameArray = tableNameAsDB.toArray(new String[0]);

        // Table selection combo box
        comboBox = new JComboBox<>(tableNameArray);
        comboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

                String selectedTable = (String) comboBox.getSelectedItem();

                if (selectedTable != null && !selectedTable.equals("Выберете таблицу из списка")) {

                    textFieldTable.setText( textFieldTable.getText() + selectedTable);

                    sqlQuery.setTableName(selectedTable);

                    try {

                        ArrayList<String> columnNames = SQLMetaData.allColumnsNameTable(conn, selectedTable);
                        ArrayList<String> columnNamesOrder = SQLMetaData.allColumnsNameTableOrder(conn, selectedTable);

                        String[] columnsArray = columnNames.toArray(new String[0]);
                        String[] columnsArrayOrder = columnNamesOrder.toArray(new String[0]);
//
                        columnsComboBox.setModel(new DefaultComboBoxModel<>(columnsArray));
                        columnsOrderComboBox.setModel(new DefaultComboBoxModel<>(columnsArrayOrder));

                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
            }
        });
        panel.add(comboBox);

        // Column selection combo box
        columnsComboBox = new JComboBox<>(new String[] {"Выберете поле из таблицы"});
        columnsComboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {


                String selectedColumn = (String) columnsComboBox.getSelectedItem();
                if (selectedColumn != null && !selectedColumn.equals("Выберете поле из таблицы")) {

                    // Update textField with column
                    textFieldColumn.setText(textFieldColumn.getText() + selectedColumn + " ");
                    sqlQuery.setColumnName(selectedColumn);
                }
            }

        });
        panel.add(columnsComboBox);

        buttonGroup = new JButton("Группировать полученные поля");
        buttonGroup.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

                textFieldGroup.setText(textFieldGroup.getText() + sqlQuery.getColumnName());

                sqlQuery.setGroupBy(true);

            }



        });
        panel.add(buttonGroup);
        
        columnsOrderComboBox = new JComboBox<>(new String[] {"Выберете поле таблицы для сортировки"});
        columnsOrderComboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

                String selectedColumnOrder = (String) columnsOrderComboBox.getSelectedItem();

                if (selectedColumnOrder != null && !selectedColumnOrder.equals("Выберете поле таблицы для сортировки")) {

                    // Update textField with column
                    textFieldOrder.setText(textFieldOrder.getText() + selectedColumnOrder + " ");

                    sqlQuery.setColumnNameOrder(selectedColumnOrder);
                    sqlQuery.setOrderBy(true);

                }
            }
        });
        panel.add(columnsOrderComboBox);


        buttonSave = new JButton("Сохранить");
        buttonSave.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

                String pathFile = saveFile.PathFile();


                if (pathFile != null) {


                    String query = sqlQuery.executeQuery();

                    System.out.println(query);
                    try {
                        SQLBuilder.queryToCSV(query,conn, pathFile);
                        SQLBuilder.saveMessage();

                    } catch (SQLException ex) {
                        throw new RuntimeException(ex);
                    } catch (FileNotFoundException ex) {
                        throw new RuntimeException(ex);
                    } catch (UnsupportedEncodingException ex) {
                        throw new RuntimeException(ex);
                    }

                }
            }
        });
        panel.add(buttonSave);
//
        buttonAgain = new JButton("Заново");
        buttonAgain.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

             sqlQuery.setAgainData();

             textFieldTable.setText("Выбрать из таблицы : ");
             textFieldColumn.setText("Выбрать поля : ");
             textFieldGroup.setText("Группировать по : ");
             textFieldOrder.setText("Сортировать по : ");

            }
        });
        panel.add(buttonAgain);

        buttonCountRow = new JButton("Количество строк");
        buttonCountRow.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

                try {
                    sqlQuery.countRow(conn);

                } catch (SQLException ex) {

                    throw new RuntimeException(ex);
                }

            }
        });
        panel.add(buttonCountRow);

        buttonAbout = new JButton("Справка");
        buttonAbout.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

                SQLBuilder.about();
            }

        });
        panel.add(buttonAbout);



        // Add panel to frame
        add(panel);
        pack();
        setSize(1000, 300);
        setResizable(false);
        setLocationRelativeTo(null);
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            try {
                new AppDataBase().setVisible(true);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        });
    }
}
