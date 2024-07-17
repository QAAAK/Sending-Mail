public class Construct {

    public static void main (String [] args){

        TestDemo t = new TestDemo("Дима", (short) 23);

    }
}


class TestDemo {


    String name;
    short age;

    public TestDemo (String name, short age) {

        this.name = name;
        this.age = age;

    }

}