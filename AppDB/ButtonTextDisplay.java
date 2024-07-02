import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.LayoutManager;
import java.sql.SQLException;
import java.util.ArrayList;
import  SQLite.*;
import RefactoringQuery.*;
import java.sql.Connection;


public class ButtonTextDisplay extends JFrame {
    private JTextField textField;
    private Connection conn = null;
    // public ArrayList<String> columns = new ArrayList<>();
    public ButtonTextDisplay() throws SQLException {

        super("App DataBase");

        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        JPanel panel = new JPanel();

        textField = new JTextField(87);
        panel.add(textField);

        ArrayList<String> tableNameAsDB = SQLite.allNamesTables(SQLite.connect(conn = null));
        String[] tableNameArray = tableNameAsDB.toArray(new String[0]);

        JComboBox<String> comboBox = new JComboBox<>(tableNameArray);
        JComboBox<String> columnsComboBox = new JComboBox<>();

        comboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String selectedItem = (String) comboBox.getSelectedItem();

                if (selectedItem != null && selectedItem != "Выберете таблицу из списка") {
                    textField.setText(textField.getText() + " " + "Выбрать из таблицы " + " " + selectedItem );
                    RefactoringQuery.getNameTable(selectedItem);

                }
            }
        });
        panel.add(comboBox);

        comboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String selectedItem = (String) comboBox.getSelectedItem();

                if (selectedItem != null && selectedItem != "Выберите поле из списка") {
                    try {
                        ArrayList<String> columnNames = SQLite.allColumnsNameTable(SQLite.connect(conn = null), selectedItem);
                        String[] columnsArray = columnNames.toArray(new String[0]);

                        DefaultComboBoxModel<String> model = new DefaultComboBoxModel<>(columnsArray);
                        columnsComboBox.setModel(model); // Обновляем модель существующего выпадающего списка

                        pack(); // Перепаковываем компоненты окна
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
            }
        });
        panel.add(columnsComboBox);






        add(panel);
        pack();

        setSize(1000, 300);
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

// class Buttons {

//     public static String isMap (String button) {

//         Map<String,String> Commands = new HashMap<String,String>();

//         Commands.put("       ", "SELECT");
//         Commands.put("               ", "GROUP BY");
//         Commands.put("              ", "ORDER BY");
//         Commands.put("          ", "FROM");
//         Commands.put("     ", "exit");


//         if (Commands.get(button) == null) {

//             return "0";

//         }

//         return  Commands.get(button);
//     }


// 	public static String refactoringButton(String button) {

// 		String refactoring_button   = button.replace(" ", "");
// 		refactoring_button = refactoring_button.substring(0, 1).toUpperCase() + refactoring_button.substring(1);

// 		return refactoring_button;
// 	}



// }


//class Query extends JFrame{
//
//
//     public static String getTextFieldText(JTextField textField) {
//
//     return textField.getText();
//
//     }
//
//
//
//      public static String queryInDatabase (String query) {
//
//      String[] items = query.split(" ");
//
//      ArrayList<String> columns = new ArrayList<>(Arrays.asList(items));
//
//      String targetQuery = String.join(",", columns);
//
//      String refreshTargetQuery = targetQuery.replace(",GROUP,", " GROUP BY ");
//      refreshTargetQuery = refreshTargetQuery.replace("ORDER,", " ORDER BY ");
//      refreshTargetQuery = refreshTargetQuery.replace("SELECT,", "SELECT ");
//      refreshTargetQuery = refreshTargetQuery.replace(", FROM,", " FROM ");
//
//
//
//      return  refreshTargetQuery;
//
//      }
//
//      public static String formatQuery (String noRefactoringQuery) {
//
//
//        String refactoringQuery = noRefactoringQuery.replace("Выбрать", "SELECT");
//        refactoringQuery = refactoringQuery.replace("Группировать по", "GROUP");
//        refactoringQuery = refactoringQuery.replace("Сортировать по", "ORDER");
//        refactoringQuery = refactoringQuery.replace("из таблицы", "FROM");
//
//        refactoringQuery = Query.queryInDatabase(refactoringQuery);
//
//        return refactoringQuery;
//
//    }




//}