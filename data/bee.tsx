<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.5" tiledversion="1.7.2" name="bee" tilewidth="64" tileheight="64" tilecount="2" columns="2" objectalignment="center">
 <image source="bee.png" width="128" height="64"/>
 <tile id="0" type="Bee">
  <objectgroup draworder="index" id="2">
   <object id="1" x="16" y="16" width="32" height="32">
    <properties>
     <property name="collidable" type="bool" value="true"/>
    </properties>
    <ellipse/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="0" duration="50"/>
   <frame tileid="1" duration="50"/>
  </animation>
 </tile>
 <tile id="1" type="Bee"/>
</tileset>
