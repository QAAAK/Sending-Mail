abstract public class Abstract {

    abstract void sayHello(String name_1);

    abstract String eat(String name_1);
}


class Human extends Abstract {

    public static String name = "Dima";

    public void sayHello (String name_1) {

        name_1 = this.name;
        System.out.println("Hello " + name_1);
    }

    public String eat(String name_1) {
        name_1 = this.name;
        return this.name + "eat...";

    }

}


class Animal extends Human {

    public static String bye (String name) {

        return name + "bye";

    }


}
