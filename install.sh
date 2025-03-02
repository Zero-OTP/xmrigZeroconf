#!/data/data/com.termux/files/usr/bin/sh

#Actualizar y descargar
echo -n "Actualizando paquetes y descargar repositorio..."
pkg upgrade
dpkg --configure -a
​pkg install git build-essential openssh -y
pkg install cmake -y
git clone https://github.com/xmrig/xmrig.git
echo -n "OK!"

#-- Reemplazar Fee al 0
echo -n "Ajustando donaciones a 0..."
cp donate.h ~/xmrig/src/donate.h
echo -n "OK!"

#-- Compilar
echo -n "Compilando en 3 segundos..."
sleep 3
mkdir xmrig/build && cd xmrig/build
#Make vanilla --> cmake .. -DWITH_HWLOC=OFF && make -j$(nproc)
#Make powered --> CFLAGS="-O3 -ffast-math -march=native -mtune=native -funroll-loops -flto" CXXFLAGS="-O3 -ffast-math -march=native -mtune=native -funroll-loops -flto" cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DWITH_ASM=ON -DWITH_HWLOC=OFF && make -j$(nproc)
CFLAGS="-O3 -ffast-math -march=native -mtune=native -funroll-loops -flto" CXXFLAGS="-O3 -ffast-math -march=native -mtune=native -funroll-loops -flto" cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DWITH_ASM=ON -DWITH_HWLOC=OFF && make -j$(nproc)
echo -n "OK!"

#-- Adecuar config
echo -n "Obtener configuracion..."
#curl --output config.json https://raw.githubusercontent.com/xmrig/xmrig/refs/heads/master/src/config.json
yes | cp ~/xmrigZeroconf/config.json ~/xmrig/build/config.json
#nano config.json
echo -n "OK!"


#-- Crear Symlink
echo -n "Crear Symlink en home..."
ln -s ~/xmrig/build/xmrig ~/xmrig-mine
echo -n "OK!"

#-- Informacion ejecutar
echo -n "Ejecuta './xmrig-mine' para iniciar el minero."
#-- Ejecutar
#./xmrig-mine
#--------------------