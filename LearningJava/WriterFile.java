import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;


public class WriterFile {

    public static void main (String [] args) throws FileNotFoundException {

        File file = new File("/File_name.txt");
        PrintWriter nw = new PrintWriter(file);

        nw.println("Hello, World!");

        nw.close();
    }
}
