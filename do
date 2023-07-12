main=`cat prj.cfg | grep main= | sed s/main=//`
kickasm=`cat tools.cfg | grep kickasm= | sed s/kickasm=//`
emulator=`cat tools.cfg | grep emulator= | sed s/emulator=//`

set -e
$kickasm  src/${main}.asm -odir ../build
( $emulator build/${main}.prg )