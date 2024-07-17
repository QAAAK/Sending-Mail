import java.io.FileNotFoundException;
import java.util.Scanner;
import java.io.File;


public class ReadFile {


    public static void main (String [] args) throws FileNotFoundException {

        File file = new File("Desktop/path_file");

        Scanner scanner = new Scanner(file);

        while (scanner.hasNextLine()) {

            System.out.println(scanner.nextLine());


        }

        scanner.close();

    }
}
