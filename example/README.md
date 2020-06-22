# Examples

1. <a href="https://github.com/marcglasberg/back_button_interceptor/blob/master/example/lib/main.dart">main</a>

   Intercepts the back-button and prints a string to the console.

2. <a href="https://github.com/marcglasberg/back_button_interceptor/blob/master/example/lib/main_complex_example.dart">main_complex_example</a>

   The first screen has a button which opens a second screen. 
   The second screen has 3 red squares. 
   By tapping the Android back-button (or the "pop" button) each square turns blue, one by one. 
   Only when all squares are blue, tapping the back-button once more will return to the previous screen.
   Also, if you click the "Open Dialog" button, the interceptors are disabled while the dialog is open.

3. <a href="https://github.com/marcglasberg/back_button_interceptor/blob/master/example/test/main_complex_example_test.dart">main_complex_example_test</a>
   
   This package is test friendly, and this examples shows how to test the back button.
