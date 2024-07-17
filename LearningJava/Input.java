import java.util.Scanner;

public class Input {
    public static void main (String [] args){

        System.out.print("Введите любое слово ");
        Scanner inputStr = new Scanner(System.in);
        String text = inputStr.nextLine();
        System.out.println("Вы ввели: " + text);



    }
}
