public class Extends_class {

    public static void main (String [] args) {

        Cata.name = "Дима";

        MoreCata str = new MoreCata();

        str.sayHello();

    }
}




class Cata {

    public static String name;

    void sayHello() {

        System.out.printf("Hello, %s", this.name);

    }

    public int sum_two_digit (int a, int b) {

        return a + b;
    }

}

class MoreCata extends Cata {
    private String name;
    public int age;

    void sayHello() {

        this.name = Cata.name;

        System.out.printf("Hello my friend %s", this.name);
    }


}