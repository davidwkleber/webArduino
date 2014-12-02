  

Table table;

void setup() {

  table = new Table();

  table.addColumn("name");
  table.addColumn("type");

  TableRow newRow = table.addRow();
  newRow.setString("name", "Lion");
  newRow.setString("type", "Mammal");

  newRow = table.addRow();
  newRow.setString("name", "Snake");
  newRow.setString("type", "Reptile");

  newRow = table.addRow();
  newRow.setString("name", "Mosquito");
  newRow.setString("type", "Insect");

  println(table.getRowCount());  // Prints 3
  saveTable(table,"data/new.csv");
  
  table.clearRows();
  println(table.getRowCount());  // Prints 0
  saveTable(table,"data/old.csv");
  
}

