// =================================================================================================
//
//	Starling Framework
//	Copyright 2012-2014 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.filters {
import com.adobe.glsl2agal.CModule;
import com.adobe.glsl2agal.compileShader;

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.utils.getTimer;

import starling.core.Starling;
import starling.textures.Texture;

public class GLSLFilter extends FragmentFilter {
    private static var glsl2agalInitialized:Boolean = false;
    private var mShaderProgram:Program3D;
    private var vs:String, fs:String;
    private var timeIdx:int = -1;

    public var errorHandler:Function;
    public var compiledVertexShader:Object;
    public var compiledFragmentShader:Object;
    public var compiledVertexShaderExport:String;
    public var compiledFragmentShaderExport:String;

    public function GLSLFilter() {
        super();

        if (!glsl2agalInitialized) {
            CModule.startAsync();
            glsl2agalInitialized = true;
        }
    }

    public override function dispose():void {
        if (mShaderProgram) mShaderProgram.dispose();
        super.dispose();
    }

    protected override function createPrograms():void {
        if (vs && fs) {
            try {
                compiledVertexShader = JSON.parse(compileShader(vs, 0, true));
                compiledVertexShaderExport = JSON.stringify(compiledVertexShader);
                trace(this, "compiledVertexShaderExport", compiledVertexShaderExport);

                mvpConstantID = compiledVertexShader.varnames["gl_ModelViewProjectionMatrix"].slice(2);
                vertexPosAtID = compiledVertexShader.varnames["gl_Vertex"].slice(2);
                texCoordsAtID = compiledVertexShader.varnames["gl_MultiTexCoord0"].slice(2);

                compiledFragmentShader = JSON.parse(compileShader(fs, 1, true));
                compiledFragmentShaderExport = JSON.stringify(compiledFragmentShader);
                trace(this, "compiledFragmentShaderExport", compiledFragmentShaderExport);

                baseTextureID = compiledFragmentShader.varnames["baseTexture"].slice(2);

                mShaderProgram = assembleAgal(compiledFragmentShader.agalasm, compiledVertexShader.agalasm);

                try {
                    timeIdx = compiledFragmentShader.varnames["time"].slice(2);
                } catch (error:Error) {
                    timeIdx = -1;
                }

                var c:String;
                var constval:Array;

                for (c in compiledFragmentShader.consts) {
                    constval = compiledFragmentShader.consts[c];
                    Starling.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, int(c.slice(2)), Vector.<Number>([constval[0], constval[1], constval[2], constval[3]]));
                }

                for (c in compiledVertexShader.consts) {
                    constval = compiledVertexShader.consts[c];
                    Starling.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, int(c.slice(2)), Vector.<Number>([constval[0], constval[1], constval[2], constval[3]]));
                }

                return;
            } catch (error:Error) {
                trace(this, "createPrograms::Error", error);
                if(errorHandler != null) {
                    errorHandler(error);
                }
            }
        }
        // Reset to the Identity filter
        trace(this, "Switching to the Identity Shader...")
        mvpConstantID = 0;
        vertexPosAtID = 0;
        texCoordsAtID = 1;
        baseTextureID = 0;
        timeIdx = -1;
        mShaderProgram = assembleAgal();
    }

    public function update(_vs:String, _fs:String):void {
        trace(this, "update");
        this.vs = _vs;
        this.fs = _fs;
        createPrograms();
    }

    private var tmpVec:Vector.<Number> = new Vector.<Number>(4);

    protected override function activate(pass:int, context:Context3D, texture:Texture):void {
        // already set by super class:
        //
        // vertex constants 0-3: mvpMatrix (3D)
        // vertex attribute 0:   vertex position (FLOAT_2)
        // vertex attribute 1:   texture coordinates (FLOAT_2)
        // texture 0:            input texture
        if (timeIdx != -1) {
            tmpVec[0] = getTimer() / 10000;
            Starling.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, timeIdx, tmpVec);
        }
        context.setProgram(mShaderProgram);
    }
}
}