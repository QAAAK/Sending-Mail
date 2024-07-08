import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.FileNotFoundException;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.util.ArrayList;
import  SQLite.*;
import RefactoringQuery.*;
import java.sql.Connection;

public class ButtonTextDisplay extends JFrame {
    private JTextField textField;
    private Connection conn = null;
    private JComboBox<String> comboBox; // Store the table combo box
    private JComboBox<String> columnsComboBox;

    private JComboBox<String> columnsOrderComboBox;

    private JButton buttonSave;
    private JButton buttonGroup;
    private JButton buttonAgain;

    public ButtonTextDisplay() throws SQLException {
        super("App DataBase");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        JPanel panel = new JPanel();

        textField = new JTextField(90);
        panel.add(textField);

        // Get table names
        ArrayList<String> tableNameAsDB = SQLite.allNamesTables(SQLite.connect(conn = null));
        String[] tableNameArray = tableNameAsDB.toArray(new String[0]);

        // Table selection combo box
        comboBox = new JComboBox<>(tableNameArray);
        comboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

                String selectedTable = (String) comboBox.getSelectedItem();

                if (selectedTable != null && !selectedTable.equals("Âûáåðåòå òàáëèöó èç ñïèñêà")) {
                    textField.setText("Âûáðàòü èç òàáëèöû " + selectedTable + " ïîëå (ïîëÿ) ");
                    RefactoringQuery.getNameTable(selectedTable);
                    // Update columns combo box
                    try {
                        ArrayList<String> columnNames = SQLite.allColumnsNameTable(SQLite.connect(conn = null), selectedTable);
                        String[] columnsArray = columnNames.toArray(new String[0]);

                        columnsComboBox.setModel(new DefaultComboBoxModel<>(columnsArray));
                        columnsOrderComboBox.setModel(new DefaultComboBoxModel<>(columnsArray));
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
            }
        });
        panel.add(comboBox);

        // Column selection combo box
        columnsComboBox = new JComboBox<>(new String[] {"Âûáåðåòå ïîëå èç ñïèñêà"});
        columnsComboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String selectedColumn = (String) columnsComboBox.getSelectedItem();
                if (selectedColumn != null && !selectedColumn.equals("Âûáåðåòå ïîëå èç ñïèñêà")) {
                    // Update textField with column
                    textField.setText(textField.getText() + " " + selectedColumn);
                    RefactoringQuery.getColumnName(selectedColumn);
                }
            }
        });
        panel.add(columnsComboBox);


        buttonGroup = new JButton("Ãðóïïèðîâàòü ïîëó÷åííûå ïîëÿ");
        buttonGroup.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

                RefactoringQuery.groupQuery();
                textField.setText(textField.getText() + " " + buttonGroup.getText());

            }
        });
        panel.add(buttonGroup);

        columnsOrderComboBox = new JComboBox<>(new String[] {"Ñîðòèðîâàòü ïî"});
        columnsOrderComboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String selectedColumnOrder = (String) columnsOrderComboBox.getSelectedItem();
                if (selectedColumnOrder != null && !selectedColumnOrder.equals("Ñîðòèðîâàòü ïî")) {
                    // Update textField with column
                    textField.setText(textField.getText() + " " + selectedColumnOrder);

                }
            }
        });
        panel.add(columnsOrderComboBox);


        buttonSave = new JButton("Ñîõðàíèòü");
        buttonSave.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                try {

                    SQLite save = new SQLite();
                    String saveLocation = save.chooseSaveLocation();

                    if (saveLocation != null) {

                        System.out.println(RefactoringQuery.resultQuery());
                        SQLite.queryToCSV(RefactoringQuery.resultQuery(), SQLite.connect(conn), saveLocation);
                        textField.setText("Ôàéë óñïåøíî ñîõðàíåí. Ïîæàëóéñòà, çàêðîéòå ïðèëîæåíèå.");
                    }
                } catch (SQLException ex) {
                    throw new RuntimeException(ex);
                } catch (FileNotFoundException ex) {
                    throw new RuntimeException(ex);
                } catch (UnsupportedEncodingException ex) {
                    throw new RuntimeException(ex);
                }
            }
        });
        panel.add(buttonSave);

        buttonAgain = new JButton("Çàíîâî");
        buttonAgain.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

                RefactoringQuery.again();
                textField.setText("");

            }
        });
        panel.add(buttonAgain);

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
                new ButtonTextDisplay().setVisible(true);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        });
    }
}
