//
//  GemPhysicsUtil.m
//  GeminiSDK
//
//  Created by James Norton on 11/10/12.
//
//

#include "GemPhysicsUtil.h"
#import "GemCircle.h"
#import "GemConvexShape.h"
#import "GemDisplayGroup.h"
#include "Box2D.h"

// utility method to return renderable shapes for each fixture associated
// with a physics body attached ot a display object.  used for debug
// phyiscs rendering.
GemDisplayGroup *getPhysicsShapes(void *vobj, float scale){
    GemDisplayObject *obj = (__bridge GemDisplayObject *)vobj;
    
    GemDisplayGroup *group = [[GemDisplayGroup alloc] initWithLuaState:NULL];
    
    group.rotation = obj.rotation;
    group.x = obj.x;
    group.y = obj.y;
    
    if (obj.physicsBody) {
        b2Body *body = (b2Body *)obj.physicsBody;
        b2Fixture *fixture = body->GetFixtureList();

        while (fixture) {
            b2Shape::Type shapeType = fixture->GetType();
            GemShape *shape;
            if ( shapeType == b2Shape::e_circle ) {
                b2CircleShape* circleShape = (b2CircleShape*)fixture->GetShape();
                GLfloat radius = circleShape->m_radius * scale;
                GLfloat x = circleShape->m_p.x * scale;
                GLfloat y = circleShape->m_p.y * scale;
                
                shape = [[GemCircle alloc] initWithLuaState:NULL X:x Y:y Radius:radius];
                
            } else if ( shapeType == b2Shape::e_polygon ) {
                b2PolygonShape* polygonShape = (b2PolygonShape*)fixture->GetShape();
                unsigned int pcount = polygonShape->GetVertexCount();
                GLfloat *points = (GLfloat *)malloc(pcount * 2 * sizeof(GLfloat));
                for (int i=0; i<pcount; i++) {
                    b2Vec2 point = polygonShape->GetVertex(i);
                    points[i*2] = point.x * scale;
                    points[i*2+1] = point.y * scale;
                }
                
                shape = [[GemConvexShape alloc] initWithLuaState:NULL Points:points NumPoints:pcount];
                //shape.x = obj.x;
                //shape.y = obj.y;
            }
            
            if (fixture->IsSensor()) {
                shape.fillColor = GLKVector4Make(1.0, 0, 0, 0.5); // transparent red
            } else {
                shape.fillColor = GLKVector4Make(0, 1.0, 0, 0.5); // transparent green
            }
            
            [group insert:shape];
            
            fixture = fixture->GetNext();
        }
        
    }
    
    return group;
}