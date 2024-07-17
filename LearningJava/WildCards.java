import java.util.ArrayList;

public class WildCards {


    public static void main (String [] args) {


        ArrayList<String> arr = new ArrayList<>();

        arr.add("Hello");
        arr.add("World");

        String output = output(arr);

    }


    public static String output (ArrayList<? extends Object> arr) {


        for (Object str : arr) {

            System.out.println(str);
        }

        return "Hi";
    }
}

