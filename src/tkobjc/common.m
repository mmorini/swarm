// Swarm library. Copyright � 1996-2000 Swarm Development Group.
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA
// 
// The Swarm Development Group can be reached via our website at:
// http://www.swarm.org/   

#include "internal.h"
#import <defobj.h> // nameToObject, OSTRDUP, SSTRDUP
#import <tkobjc/global.h>
#import <tkobjc/Widget.h>
#import <tkobjc/common.h>

void
tkobjc_dragAndDropTarget (id target, id object)
{
  [globalTkInterp
    eval:
      "drag&drop target %s handler id {%s idReceive: %%W}",
    [target getWidgetName],
    [object getObjectName]];
}

static void
dragAndDropTargetArg (id target, id object, int arg)
{
  [globalTkInterp
    eval: "drag&drop target %s handler id {%s idReceive: %%W arg: %d}", 
    [target getWidgetName],
    [object getObjectName],
    arg];
}

static void
oldSetupDragAndDrop (id source, id object)
{
  const char *objectName = [object getObjectName];
  const char *sourceWidgetName = [source getWidgetName];
  
  [globalTkInterp
    eval: "drag&drop source %s config -packagecmd {do_package %s} -sitecmd sitecmd -button 1", 
    sourceWidgetName,
    objectName];
}

static void
newSetupDragAndDrop (id source, id object)
{
  const char *objectName = [object getObjectName];
  const char *sourceWidgetName = [source getWidgetName];

  [globalTkInterp
    eval: "drag&drop source %s -packagecmd {do_package %s %%t} -sitecmd {sitecmd %%s %%t} -button 1", 
    sourceWidgetName,
    objectName];
}

static void
setupDragAndDrop (id source, id object)
{
  if ([globalTkInterp newBLTp])
    newSetupDragAndDrop (source, object);
  else
    oldSetupDragAndDrop (source, object);
}

static void
oldSetupDragAndDropArg (id source, id object, int arg)
{
  const char *sourceWidgetName = [source getWidgetName];
  const char *objectName = [object getObjectName];

  [globalTkInterp
    eval: "drag&drop source %s config -packagecmd {do_package_arg %s %d} -sitecmd sitecmd -button 1",
    sourceWidgetName,
    objectName,
    arg];
}

static void
newSetupDragAndDropArg (id source, id object, int arg)
{
  const char *sourceWidgetName = [source getWidgetName];
  const char *objectName = [object getObjectName];

  [globalTkInterp
    eval: "drag&drop source %s -packagecmd {do_package_arg %s %d %%t} -sitecmd {sitecmd %%s %%t} -button 1", 
    sourceWidgetName,
    objectName,
    arg];
}

void
tkobjc_setupDragAndDropArg (id source, id object, int arg)
{
  if ([globalTkInterp newBLTp])
    newSetupDragAndDropArg (source, object, arg);
  else
    oldSetupDragAndDropArg (source, object, arg);
}

static void
oldSetupHandler (id source)
{
  [globalTkInterp
    eval: "drag&drop source %s handler id send_id", 
    [source getWidgetName]];
}

static void
newSetupHandler (id source)
{
  [globalTkInterp
    eval: "drag&drop source %s handler id {send_id %%i %%w %%v}", 
    [source getWidgetName]];
}

void
tkobjc_setupHandler (id source)
{
  if ([globalTkInterp newBLTp])
    newSetupHandler (source);
  else
    oldSetupHandler (source);
}

void
tkobjc_dragAndDrop (id source, id object)
{
  setupDragAndDrop (source, object);
  tkobjc_setupHandler (source);
}

void
tkobjc_dragAndDropArg (id source, id object, int arg)
{
  dragAndDropTargetArg (source, object, arg);
  tkobjc_setupDragAndDropArg (source, object, arg);
  tkobjc_setupHandler (source);
}

int
tkobjc_doOneEventSync (void)
{
  return Tk_DoOneEvent (TK_ALL_EVENTS);
}

int
tkobjc_doOneEventAsync (void)
{
  return Tk_DoOneEvent(TK_ALL_EVENTS|TK_DONT_WAIT);
}

void
tkobjc_configureSpecialBitmap (id widget)
{
  [globalTkInterp
    eval: 
      "%s configure -bitmap special -activeforeground red -foreground red",
    [widget getWidgetName]];
}

void
tkobjc_bindButton3ToSpawn (id widget, id self, int focusFlag)
{
  const char *widgetName = [widget getWidgetName];

  if (focusFlag)
    [globalTkInterp
      eval:
        "bind %s <Button-3> {focus %s ; %s configure -highlightcolor red ;"
      "update ; %s Spawn: %s; %s configure -highlightcolor black ;"
      "update ; focus %s ; update } ;",
      widgetName,
      widgetName,
      widgetName,
      [self getObjectName],
      widgetName,
      widgetName,
      widgetName];
  else
    [globalTkInterp
      eval:
        "bind %s <Button-3> {focus %s; %s configure -highlightcolor red;"
      "update;"
      "%s Spawn: %s;"
      "%s configure -highlightcolor black;"
      "update};",
      widgetName,
      widgetName,
      widgetName,
      [self getObjectName],
      widgetName,
      widgetName];
}

void
tkobjc_bindButton3ToArgSpawn (id widget, id self, int which)
{
  const char *widgetName = [widget getWidgetName];

  [globalTkInterp
    eval:
      "bind %s <Button-3> {focus %s ; %s configure -highlightcolor red ;"
    "update ; %s argSpawn: %s arg: %d ; %s configure -highlightcolor black ;"
    "update ; focus %s ; update } ;",
    widgetName,
    widgetName,
    widgetName,
    [self getObjectName],
    widgetName,
    which,
    widgetName,
    widgetName];
}

void
tkobjc_ringBell (void)
{
  [globalTkInterp eval: "bell"] ;
}

const char *
tkobjc_dynamicEval (const char *cmd)
{
  [globalTkInterp eval: "%s", cmd];
  return SSTRDUP (([globalTkInterp result]));
}

id
tkobjc_drag_and_drop_object (void)
{
  const char *name;

  [globalTkInterp eval: "gimme_ddobj"];
  name = [globalTkInterp result];
  return nameToObject (name);
}

void
tkobjc_update (void)
{
  [globalTkInterp eval: "update"];
}

void
tkobjc_releaseAndUpdate (void)
{
#ifndef _WIN32
  [globalTkInterp eval: "foreach w [busy isbusy] {busy release $w} ; update"];
#endif
}

void
tkobjc_updateIdleTasks (int hold)
{
  [globalTkInterp eval:
                    "update idletasks"];

#ifndef _WIN32
  if (hold)
    [globalTkInterp eval:
                  "foreach w [winfo children .] {busy hold $w} ;"
                    "update"];
#endif
}

void
tkobjc_focus (id widget)
{
  [globalTkInterp eval: "focus %s", [widget getWidgetName]];
}

void
tkobjc_makeFrame (id widget)
{
  [globalTkInterp eval: "frame %s", [widget getWidgetName]];
}

void
tkobjc_pack (id widget)
{
  [globalTkInterp eval: "pack %s -fill both -expand true;",
                  [widget getWidgetName]];
}


const char *
tkobjc_createText (id aZone,
                   id widget, int x, int y,
                   const char *text, const char *font,
                   BOOL centerFlag)
{
  return ZSTRDUP (aZone,
                  ([[globalTkInterp 
                      eval: 
                        "%s create text %d %d -text \"%s\" %s%s -anchor %s", 
                      [widget getWidgetName], x, y, text, 
                      (font ? "-font " : ""),
                      (font ? font : ""),
                      (centerFlag ? "c" : "w")]
                     result]));
}
