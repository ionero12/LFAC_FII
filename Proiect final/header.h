enum nodetype{
     OP = 1,
     IDENTIF = 2,
     NUMAR = 3,
     VECTOR = 4,
     OTHERS = 5
};

struct variabila_info
{
     char name[50];
     char type[50]; 
     int val;
     int scope;
     char str_val[50];
     int if_const;
     int array_size;
     int* array;
     int* has_elements;
};

struct functie_info
{
     char func_name[50];
     char list_of_types[50];
     char func_return_type[50];
     unsigned int nr_of_args;
};

struct AST
{
     struct AST* left;
     struct AST* right;
     enum nodetype node_type;
     char* name;
};
