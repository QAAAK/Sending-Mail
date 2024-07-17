

import java.util.HashSet;
import java.util.HashMap;//import HashSet Class

public class Hash {
    public static void main(String[] args) {
        // Create a new HashSet to store strings
        HashSet<String> elements = new HashSet<String>();

        elements.add("apple");
        elements.add("apple");
        elements.add("blueberry");
        elements.add("lemon");

        System.out.println(elements);


        HashMap<String, Integer> map = new  HashMap <>();
// Добавляем элементы в Map
        map.put("apple", 1);
        map.put("banana", 2);
        map.put("orange", 3);

        // This HashSet can now be used to add elements, remove elements, etc.


        System.out.println(map);
    }
}
