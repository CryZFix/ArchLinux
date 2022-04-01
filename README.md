# ВНИМАНИЕ!
Скрипт затирает диск dev/sda в системе. Поэтому если у вас есть ценные данные на дисках сохраните их. Если вам нужна установка рядом с Windows, тогда вам нужно предварительно изменить скрипт и разметить диски. В противном случае данные и Windows будут затерты. Он предназначет для тех, кто ставил ArchLinux руками и понимает, что и для чего нужна каждая команда. 

# Использование 
1) Запустившись с ранее подготовленного ISO-образа, скачать и запустить скрипт командой:

   ```bash 
   wget git.io/al_fast_installer.sh && sh al_fast_installer.sh
   ```
   или
   
    ```bash
   curl -OL git.io/al_fast_installer.sh && sh al_fast_installer.sh
   ```