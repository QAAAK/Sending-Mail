package Interface_demo;

public class Demo {
}


class Interface implements Animal_method {

    public void hello (String name) {

        System.out.println("hello " + name);
    }

    public int sum (int num1, int num3) {

        return num1 + num3;
    }

}