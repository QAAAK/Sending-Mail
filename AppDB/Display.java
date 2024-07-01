import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.Arrays;

public class ButtonTextDisplay extends JFrame {
    private JTextField textField;
    // public ArrayList<String> columns = new ArrayList<>();

    public ButtonTextDisplay() {
        super("App DataBase");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        JPanel panel = new JPanel();

        textField = new JTextField(87);

        panel.add(textField);

        JButton button_select = new JButton("Выбрать");
        button_select.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                textField.setText(textField.getText() + "" + button_select.getText());
            }
        });
        panel.add(button_select);

        JComboBox<String> comboBox = new JComboBox<>(new String[]{"Выбрать поле из списка","name", "age ", "phone_num"});
        comboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String selectedItem = (String) comboBox.getSelectedItem();

                if (selectedItem != null && selectedItem != "Выбрать поле из списка") {
                    textField.setText(textField.getText() + " " + selectedItem );
                }

            }
        });
        panel.add(comboBox);

        JButton button_group = new JButton("Группировать по");
        button_group.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                textField.setText(textField.getText() + " " + button_group.getText());
            }
        });
        panel.add(button_group);

        JButton button_order = new JButton("Сортировать по");
        button_order.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                textField.setText(textField.getText() + " " + button_order.getText());
            }
        });
        panel.add(button_order);

        JButton button_from_table = new JButton("из таблицы");
        button_from_table.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                textField.setText(textField.getText() + " " + button_from_table.getText());
            }
        });
        panel.add(button_from_table);

        JComboBox<String> comboBoxTable = new JComboBox<>(new String[]{"Выбрать таблицу из списка","Customer", "Album", ""});
        comboBoxTable.addActionListener(new ActionListener() { // 
            @Override
            public void actionPerformed(ActionEvent e) {
                String selectedItemTable = (String) comboBoxTable.getSelectedItem();
                if (selectedItemTable != null && selectedItemTable != "Выбрать таблицу из списка") {
                    textField.setText(textField.getText() + " " + selectedItemTable);
                }
            }
        });
        panel.add(comboBoxTable);

        JButton button_save = new JButton("Сохранить");
        button_save.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

                String textToSave = Query.getTextFieldText(textField);

                System.out.println(Query.formatQuery(textToSave));




            }
        });
        panel.add(button_save);

        add(panel);
        pack();

        setSize(1000, 300);
        setLocationRelativeTo(null);

    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            new ButtonTextDisplay().setVisible(true);
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


class Query extends JFrame{
    

     public static String getTextFieldText(JTextField textField) {

     return textField.getText(); 

     }
    
    
    
      public static String queryInDatabase (String query) {
          
      String[] items = query.split(" ");  
      
      ArrayList<String> columns = new ArrayList<>(Arrays.asList(items));

      String targetQuery = String.join(",", columns);

      String refreshTargetQuery = targetQuery.replace(",GROUP,", " GROUP BY ");
      refreshTargetQuery = refreshTargetQuery.replace("ORDER,", " ORDER BY ");
      refreshTargetQuery = refreshTargetQuery.replace("SELECT,", "SELECT ");
      refreshTargetQuery = refreshTargetQuery.replace(", FROM,", " FROM ");
      
      
        
      return  refreshTargetQuery; 
        
      }

      public static String formatQuery (String noRefactoringQuery) {


        String refactoringQuery = noRefactoringQuery.replace("Выбрать", "SELECT");
        refactoringQuery = refactoringQuery.replace("Группировать по", "GROUP");
        refactoringQuery = refactoringQuery.replace("Сортировать по", "ORDER");
        refactoringQuery = refactoringQuery.replace("из таблицы", "FROM");
        
        refactoringQuery = Query.queryInDatabase(refactoringQuery);

        return refactoringQuery;

    }
    
    
    
  
    


	
    



}
