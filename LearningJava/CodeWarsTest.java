public class CodeWarsTest {


    public static void main (String [] args) {

        Cata cata = new Cata();
        cata.setcata("Дима", 23);
        cata.getcata();
    }
}

class Cata {

    private String name;
    private int age;

    public void setcata(String name, int age) {

        this.name = name;
        this.age = age;

    }

    public void getcata() {

        System.out.println("Это наши переменные: " + this.name + " " + this.age);

    }

}