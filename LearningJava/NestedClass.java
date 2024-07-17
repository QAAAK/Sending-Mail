public class NestedClass {


    public static void main (String [] args) {

        Nested test = new Nested("Дима", 23);

    }

    private static class Nested {

        int age;
        String name;


        private Nested(String name, int age) {
            this.age = age;
            this.name = name;
        }


    }


    
}
