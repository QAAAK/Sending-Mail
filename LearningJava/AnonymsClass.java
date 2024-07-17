public class AnonymsClass {

    public static void main (String [] args) {

        Test t = new Test() {
            public void eat() {

                System.out.print("Eat 2");
            }
        };

        t.eat();

    }
}


class Test {

    public void eat () {

        System.out.print("Eaaat...");

    }

}