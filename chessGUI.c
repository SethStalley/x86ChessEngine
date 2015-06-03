#include <gtk/gtk.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

//use asm global bitmaps to load board later
extern long long whitePawns;

long long gui; //gui bitmap

extern long long aiPlayer;  //current player AI uses

extern ai();

/*
gcc chessGUI.c -o run `pkg-config --cflags --libs gtk+-2.0`
*/

//function to get pointer on click event
GdkWindow*    gdk_window_get_pointer     (GdkWindow       *window,
					  gint            *x,
					  gint            *y,
					  GdkModifierType *mask);

int board[64];
GtkWidget *window;
GtkWidget *layout;
GtkWidget *image;
GtkWidget *button, *bMove; //butons
GtkLayout* label;
GtkEntry* entry;
char path[1024]; //img folder path
char tempPath[1024];
int gameOver = 0;
//string of input chars
char *arg1;
char *arg2;

void addPiecesGui();
static void addLabels();
void createWindow();
void loadLayout();
void move();

int pieceSelected = 0;


void movePiece(int movPos){
    //copy over current bitMaps to temp vars
    long long selectedPiece = 0x1;
    selectedPiece <<= (pieceSelected -1);
    long long movPosition = 0x1;
    movPosition <<= (movPos -1);

    int doMove = 0;

    long long guiPiece, buffer, *pieceMoveBoard;
    int i, j;
    //remove selected Piece
    for(i = 0; i<12; i++){
        //for bitmap of every piece type
        guiPiece = *(&whitePawns+i);
        buffer = guiPiece & selectedPiece;
        if(buffer){//this bitmap has piece
            *(&whitePawns+i) = guiPiece ^ selectedPiece;
            pieceMoveBoard = (&whitePawns+i);
            doMove = 1;
            break;
        }
    }

    for(i = 0; i<12; i++){
        //for bitmap of every piece type
        guiPiece = *(&whitePawns+i);
        buffer = guiPiece & movPosition;
        if(buffer){//this bitmap has piece
            *(&whitePawns+i) = guiPiece ^ movPosition;
            break;
        }
    }

    //do the move
    if(doMove){
        *pieceMoveBoard |= movPosition;
        move();
    }
    pieceSelected = 0;
}

//when a mouse button is pressed
static gboolean
button_press_event(GtkWidget *widget, GdkEventButton *event )
{
  if (event->button == 1 && event->y <=800
            && event-> x <= 800){
    int x = event->x / 100 + 1;
    int y = abs(event->y / 100 - 9);
    //get the bit position
    int position = x+((y-1)*8);
    if(!pieceSelected){
        pieceSelected = position;  //select the piece to move
        //add hightlight image
        int imgx = (((position-1)%8) * 100);
        int imgy = (abs(((position-1)/8)-7) * 100);
        loadLayout();
        strcpy(tempPath, path);
        image = gtk_image_new_from_file(strcat(tempPath, "highlight.png"));
        gtk_layout_put(GTK_LAYOUT(layout), image, imgx, imgy);
        gtk_widget_show_all(window);
    }else{
        if(position == pieceSelected){
            pieceSelected = 0;
            loadLayout();
        }else
            movePiece(position);
    }

  }
  return TRUE;
}


//do a move
void move(){
    //parse initial game options
    //if computer vs computer
    if(!strcmp(arg1,"-c") && !strcmp(arg2, "-c")){
        ai(); //computer vs computer game
        printf("AI Moved\n");
    //if human vs human
    }else if(!strcmp(arg1,"-h") && !strcmp(arg2, "-h")){
        printf("Human Moved\n");
    }else if(!strcmp(arg1,"-h") && !strcmp(arg2, "-c")){
        if(aiPlayer ==1){
            printf("Human Moved\n");
        }else{
            ai();
            printf("Computer Moved\n");
        }
    }else if(!strcmp(arg1,"-c") && !strcmp(arg2, "-h")){
        puts("HERE");
        if(aiPlayer ==1){
            ai();
            printf("Computer Moved\n");
        }else{
            printf("Human Moved\n");
        }
    }

    //ai to move
    loadLayout();
    aiPlayer *= -1;
}


//int initGui( int   argc, char *argv[] )
int main(int argc, char *argv[])
{
    //if game settings entered
    if(argc != 3){
        printf("%s\n", "Please enter init game flags.\n"
        "Ex: \"./Chess -h -c\"");
        return 0;
    }

    arg1 = argv[1];
    arg2 = argv[2];
    aiPlayer = 1;

	//get running dir put in swd
   	getcwd(path, sizeof(path));
	strcat(path, "/img/");

    //LOAD GUI
	gtk_init(&argc, &argv);
   	createWindow();

	loadLayout();

    //close on exit
    g_signal_connect_swapped(G_OBJECT(window), "destroy",
        G_CALLBACK(gtk_main_quit), NULL);

    gtk_signal_connect (GTK_OBJECT (window), "button_press_event",
              (GtkSignalFunc) button_press_event, NULL);

    gtk_main ();

    return 0;
}

void createWindow(){
    //create new window
    window = gtk_window_new (GTK_WINDOW_TOPLEVEL);

    // Set the window title
    gtk_window_set_title (GTK_WINDOW (window), "Chess");

    //set window size
    gtk_window_set_default_size(
        GTK_WINDOW(window), 800, 850);

    layout = gtk_layout_new(NULL, NULL);
    gtk_container_add(GTK_CONTAINER (window), layout);
}

void loadLayout(){
	//refresh the layout widget
	gtk_container_remove(GTK_CONTAINER(window), layout);

    layout = gtk_layout_new(NULL, NULL);
    gtk_container_add(GTK_CONTAINER (window), layout);
	strcpy(tempPath, path);
    image = gtk_image_new_from_file(
        strcat(tempPath, "chessBoard.svg"));
    gtk_layout_put(GTK_LAYOUT(layout), image, 0, 0);

	//do the move button
	bMove = gtk_button_new_with_label("MOVE");
	gtk_widget_show(bMove);
	gtk_layout_put(GTK_LAYOUT(layout), bMove, 725,815);
    gtk_signal_connect(GTK_OBJECT(bMove), "clicked",
                       GTK_SIGNAL_FUNC(move),NULL);

    //mouse listener
    gtk_widget_set_events (window,GDK_BUTTON_PRESS_MASK);


    gtk_widget_show(layout);
    gtk_widget_show_all(window);

    addPiecesGui();



}

void callback( GtkWidget *widget,
               gpointer   data )
{
    GtkEntry* entry = (GtkEntry*)data;

    printf("on_button_clicked - entry = '%s'\n", gtk_entry_get_text(entry));
    fflush(stdout);
}

//add pieces to board in gui from global bitmaps
void addPiecesGui(){
    int i, j;
    //clear the board first
    for(i = 0; i<64; i++){
        board[i] = 0;
    }
    //copy over current bitMaps to temp vars
    long long guiPiece = whitePawns;

    //add all pieces to board from bitmaps
    for(i = 0; i<12; i++){
            //for bitmap of every piece type
            guiPiece = *(&whitePawns+i);
            //check for a bit on
            long long bitChecker = 0x1;
        for(j = 0; j<64;j++){
            int pieceHere = (bitChecker & guiPiece) == 0 ? 0:1;
            if(pieceHere)
                //asign piece type
                board[j] = i + 1;
            //shift bitChecker one bit left
            bitChecker <<= 1;
        }
    }

    //add images for each piece on board
  for(i = 0; i<64; i++){
  	int position = i;
  	int x = ((i%8) * 100) + 20;
  	int y = (abs((i/8)-7) * 100) + 20;
  	strcpy(tempPath, path);
        switch(board[i]){
          case 1:
              image = gtk_image_new_from_file(strcat(tempPath, "wpawn.png"));
              gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
              break;
          case 2:
              image = gtk_image_new_from_file(strcat(tempPath, "wbishop.png"));
              gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
 	         break;
        	case 3:
                    image = gtk_image_new_from_file(strcat(tempPath, "wknight.png"));
                    gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
        	    break;
        	case 4:
                    image = gtk_image_new_from_file(strcat(tempPath, "wrook.png"));
                    gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
        	    break;
        	case 5:
                    image = gtk_image_new_from_file(strcat(tempPath, "wqueen.png"));
                    gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
        	    break;
        	case 6:
                    image = gtk_image_new_from_file(strcat(tempPath, "wking.png"));
                    gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
        	    break;
        	case 7:
                    image = gtk_image_new_from_file(strcat(tempPath, "bpawn.png"));
                    gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
        	    break;
        	case 8:
                    image = gtk_image_new_from_file(strcat(tempPath, "bbishop.png"));
                    gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
        	    break;
        	case 9:
                    image = gtk_image_new_from_file(strcat(tempPath, "bknight.png"));
                    gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
        	    break;
        	case 10:
                    image = gtk_image_new_from_file(strcat(tempPath, "brook.png"));
                    gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
        	    break;
        	case 11:
                    image = gtk_image_new_from_file(strcat(tempPath, "bqueen.png"));
                    gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
        	    break;
        	case 12:
                    image = gtk_image_new_from_file(strcat(tempPath, "bking.png"));
                    gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
        	    break;
        }
    }
    gtk_widget_show_all(layout);
}
