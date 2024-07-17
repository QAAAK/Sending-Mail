import java.util.ArrayList;



public class Generics {


    public static void main(String[] args) {

        ArrayList<String> arr = new ArrayList<>();

        arr.add("Hello");
        arr.add("World");
        arr.add("Dima!");

        String str = String.join(",", arr);

        System.out.println(str);

        System.out.println(arr.contains("Hello"));
    }
}
