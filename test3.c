// while case, just example
int main() {
  int a = 1;

  while(a < 10) {
    int b = 0;
    b = a * 1000;
    digitalWrite(13, HIGH);
    delay(b);
    digitalWrite(13, LOW);
    delay(b);
    a=a+1;
  }
  return 0;
}
