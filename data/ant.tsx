<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.5" tiledversion="1.7.2" name="ant" tilewidth="32" tileheight="16" tilecount="4" columns="4" objectalignment="bottom">
 <image source="ant.png" width="128" height="16"/>
 <tile id="0" type="Ant">
  <properties>
   <property name="name" value="empty"/>
  </properties>
  <objectgroup draworder="index" id="2">
   <object id="2" x="16" y="0">
    <properties>
     <property name="collidable" type="bool" value="true"/>
     <property name="sensor" type="bool" value="true"/>
    </properties>
    <polygon points="0,4 -12,8 0,12 12,8"/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="0" duration="50"/>
   <frame tileid="1" duration="50"/>
  </animation>
 </tile>
 <tile id="1" type="Ant">
  <objectgroup>
   <object id="1" x="16" y="0">
    <properties>
     <property name="collidable" type="bool" value="true"/>
     <property name="sensor" type="bool" value="true"/>
    </properties>
    <polygon points="0,4 -12,8 0,12 12,8"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="2" type="Ant">
  <properties>
   <property name="name" value="full"/>
  </properties>
  <objectgroup>
   <object id="1" x="16" y="0">
    <properties>
     <property name="collidable" type="bool" value="true"/>
     <property name="sensor" type="bool" value="true"/>
    </properties>
    <polygon points="0,4 -12,8 0,12 12,8"/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="2" duration="50"/>
   <frame tileid="3" duration="50"/>
  </animation>
 </tile>
 <tile id="3" type="Ant">
  <objectgroup>
   <object id="1" x="16" y="0">
    <properties>
     <property name="collidable" type="bool" value="true"/>
     <property name="sensor" type="bool" value="true"/>
    </properties>
    <polygon points="0,4 -12,8 0,12 12,8"/>
   </object>
  </objectgroup>
 </tile>
</tileset>
