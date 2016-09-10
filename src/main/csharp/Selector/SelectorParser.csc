/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// ----------------------------------------------------------------------------
// OPTIONS
// ----------------------------------------------------------------------------
options {
  STATIC = false;
  UNICODE_INPUT = true;
  
  // some performance optimizations
  OPTIMIZE_TOKEN_MANAGER = true;
  ERROR_REPORTING = false;
}

// ----------------------------------------------------------------------------
// PARSER
// ----------------------------------------------------------------------------

PARSER_BEGIN(SelectorParser)
/**
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
using System;
using System.IO;
using System.Text;
using System.Collections;

using Apache.NMS;

//namespace Apache.NMS.Selector
//{
    /// <summary>
    /// JMS Selector Parser generated by <a href="https://github.com/deveel/csharpcc">CSharpCC</a>
    /// 
    /// Do not edit this .cs file directly - it is autogenerated from SelectorParser.csc
    /// using <c>csharpcc.exe -UNICODE_INPUT=true SelectorParser.csc</c>.
    /// 
    /// SelectorParser.csc is adapted from
    /// <a href="https://raw.githubusercontent.com/apache/activemq/activemq-4.0/activemq-core/src/main/grammar/SelectorParser.jj">
    /// ActiveMQ 4.0 SelectorParser.jj</a>
    /// </summary>
    public class SelectorParser
    {

        public SelectorParser()
        {
        }

        public IBooleanExpression Parse(string selector)
        {
            this.ReInit(new StringReader(selector));

            try
            {
                return this.JmsSelector();
            } 
            catch(Exception e)
            {
	            throw new InvalidSelectorException(selector, e);
            }
        }

        private IBooleanExpression AsBooleanExpression(IExpression value)
        {
            if(value is IBooleanExpression)
            {
                return (IBooleanExpression)value;
            }
            if(value is PropertyExpression)
            {
                return UnaryExpression.CreateBooleanCast(value);
            }
            throw new ParseException("IExpression will not result in a boolean value: " + value);
        }
    }

//}

PARSER_END(SelectorParser)

// ----------------------------------------------------------------------------
// Tokens
// ----------------------------------------------------------------------------

/* White Space */
SPECIAL_TOKEN :
{
  " " | "\t" | "\n" | "\r" | "\f"
}

/* Comments */
SKIP:
{
  <LINE_COMMENT: "--" (~["\n","\r"])* ("\n"|"\r"|"\r\n") >
}

SKIP:
{
  <BLOCK_COMMENT: "/*" (~["*"])* "*" ("*" | (~["*","/"] (~["*"])* "*"))* "/">
}

/* Reserved Words */
TOKEN [IGNORE_CASE] :
{
    <  NOT     : "NOT">
  | <  AND     : "AND">
  | <  OR      : "OR">
  | <  BETWEEN : "BETWEEN">
  | <  LIKE    : "LIKE">
  | <  ESCAPE  : "ESCAPE">
  | <  IN      : "IN">
  | <  IS      : "IS">
  | <  TRUE    : "TRUE" >
  | <  FALSE   : "FALSE" >
  | <  NULL    : "NULL" >
  | <  XPATH   : "XPATH" >
  | <  XQUERY  : "XQUERY" >
}

/* Literals */
TOKEN [IGNORE_CASE] :
{

    < DECIMAL_LITERAL: ["1"-"9"] (["0"-"9"])* (["l","L"])? >
  | < HEX_LITERAL: "0" ["x","X"] (["0"-"9","a"-"f","A"-"F"])+ >
  | < OCTAL_LITERAL: "0" (["0"-"7"])* >  
  | < FLOATING_POINT_LITERAL:  		  
          (["0"-"9"])+ "." (["0"-"9"])* (<EXPONENT>)? // matches: 5.5 or 5. or 5.5E10 or 5.E10
        | "." (["0"-"9"])+ (<EXPONENT>)?              // matches: .5 or .5E10
        | (["0"-"9"])+ <EXPONENT>                     // matches: 5E10
    >
  | < #EXPONENT: "E" (["+","-"])? (["0"-"9"])+ >
  | < STRING_LITERAL: "'" ( ("''") | ~["'"] )*  "'" >
}

TOKEN [IGNORE_CASE] :
{
    < ID : ["a"-"z", "_", "$"] (["a"-"z","0"-"9","_", "$"])* >
}

// ----------------------------------------------------------------------------
// Grammar
// ----------------------------------------------------------------------------
IBooleanExpression JmsSelector() :
{
    IExpression left = null;
}
{
    (
        left = GetOrExpression()
    ) 
    {
        return AsBooleanExpression(left);
    }

}

IExpression GetOrExpression() :
{
    IExpression left;
    IExpression right;
}
{
    (
        left = GetAndExpression() 
        ( 
            <OR> right = GetAndExpression() 
            {
                left = LogicExpression.CreateOR(AsBooleanExpression(left), AsBooleanExpression(right));
            }
        )*
    ) 
    {
        return left;
    }

}


IExpression GetAndExpression() :
{
    IExpression left;
    IExpression right;
}
{
    (
        left = GetEqualityExpression() 
        ( 
            <AND> right = GetEqualityExpression() 
            {
                left = LogicExpression.CreateAND(AsBooleanExpression(left), AsBooleanExpression(right));
            }
        )*
    ) 
    {
        return left;
    }
}

IExpression GetEqualityExpression() :
{
    IExpression left;
    IExpression right;
}
{
    (
        left = GetComparisonExpression() 
        ( 
            
            "=" right = GetComparisonExpression() 
            {
                left = ComparisonExpression.CreateEqual(left, right);
            }
            |            
            "<>" right = GetComparisonExpression() 
            {
                left = ComparisonExpression.CreateNotEqual(left, right);
            }
            |            
            LOOKAHEAD(2)
            <IS> <NULL>
            {
                left = ComparisonExpression.CreateIsNull(left);
            }
            |            
            <IS> <NOT> <NULL>
            {
                left = ComparisonExpression.CreateIsNotNull(left);
            }
        )*
    ) 
    {
        return left;
    }
}

IExpression GetComparisonExpression() :
{
    IExpression left;
    IExpression right;
    IExpression low;
    IExpression high;
    string t;
    string u;
	ArrayList list;
}
{
    (
        left = GetAddExpression() 
        ( 
            
                ">" right = GetAddExpression() 
                {
                    left = ComparisonExpression.CreateGreaterThan(left, right);
                }
            |            
                ">=" right = GetAddExpression() 
                {
                    left = ComparisonExpression.CreateGreaterThanOrEqual(left, right);
                }
            |            
                "<" right = GetAddExpression() 
                {
                    left = ComparisonExpression.CreateLesserThan(left, right);
                }
            |            
                "<=" right = GetAddExpression() 
                {
                    left = ComparisonExpression.CreateLesserThanOrEqual(left, right);
                }
           |
				{
					u = null;
				}           		
		        <LIKE> t = GetStringLitteral() 
		        	[ <ESCAPE> u = GetStringLitteral() ]
		        {
                    left = ComparisonExpression.CreateLike(left, t, u);
		        }
           |
	        	LOOKAHEAD(2)
				{
					u=null;
				}           		
		        <NOT> <LIKE> t = GetStringLitteral() [ <ESCAPE> u = GetStringLitteral() ]
		        {
                    left = ComparisonExpression.CreateNotLike(left, t, u);
		        }
            |
		        <BETWEEN> low = GetAddExpression() <AND> high = GetAddExpression()
		        {
					left = ComparisonExpression.CreateBetween(left, low, high);
		        }
	        |
	        	LOOKAHEAD(2)
		        <NOT> <BETWEEN> low = GetAddExpression() <AND> high = GetAddExpression()
		        {
					left = ComparisonExpression.CreateNotBetween(left, low, high);
		        }
            |
				<IN> 
		        "(" 
		            t = GetStringLitteral()
		            {
			            list = new ArrayList();
			            list.Add(t);
		            }
			        ( 
			        	","
			            t = GetStringLitteral() 
			            {
				            list.Add(t);
			            }
			        	
			        )*
		        ")"
		        {
		           left = ComparisonExpression.CreateIn(left, list);
		        }
            |
	        	LOOKAHEAD(2)
	            <NOT> <IN> 
		        "(" 
		            t = GetStringLitteral()
		            {
			            list = new ArrayList();
			            list.Add(t);
		            }
			        ( 
			        	","
			            t = GetStringLitteral() 
			            {
				            list.Add(t);
			            }
			        	
			        )*
		        ")"
		        {
		           left = ComparisonExpression.CreateNotIn(left, list);
		        }
            
        )*
    ) 
    {
        return left;
    }
}

IExpression GetAddExpression() :
{
    IExpression left;
    IExpression right;
}
{
    left = GetMultiplyExpression() 
    ( 
	    LOOKAHEAD( ("+"|"-") GetMultiplyExpression())
	    (
	        "+" right = GetMultiplyExpression() 
	        {
	            left = ArithmeticExpression.CreatePlus(left, right);
	        }
	        |            
	        "-" right = GetMultiplyExpression() 
	        {
	            left = ArithmeticExpression.CreateMinus(left, right);
	        }
        )
        
    )*
    {
        return left;
    }
}

IExpression GetMultiplyExpression() :
{
    IExpression left;
    IExpression right;
}
{
    left = GetUnaryExpression() 
    ( 
        "*" right = GetUnaryExpression() 
        {
	        left = ArithmeticExpression.CreateMultiply(left, right);
        }
        |            
        "/" right = GetUnaryExpression() 
        {
	        left = ArithmeticExpression.CreateDivide(left, right);
        }
        |            
        "%" right = GetUnaryExpression() 
        {
	        left = ArithmeticExpression.CreateMod(left, right);
        }
        
    )*
    {
        return left;
    }
}


IExpression GetUnaryExpression() :
{
    IExpression left = null;
}
{
	(
		LOOKAHEAD( "+" GetUnaryExpression() )
	    "+" left = GetUnaryExpression()
	    |
	    "-" left = GetUnaryExpression()
	    {
	        left = UnaryExpression.CreateNegate(left);
	    }
	    |
	    <NOT> left = GetUnaryExpression()
	    {
		    left = UnaryExpression.CreateNOT(AsBooleanExpression(left));
	    }
	    |
	    left = GetPrimaryExpression()
    )
    {
        return left;
    }

}

IExpression GetPrimaryExpression() :
{
    IExpression left = null;
}
{
    (
        left = GetLiteral()
        |
        left = GetVariable()
        |
        "(" left = GetOrExpression() ")"
    ) 
    {
        return left;
    }
}



ConstantExpression GetLiteral() :
{
    Token t;
    string s;
    ConstantExpression left = null;
}
{
    (
        (
            s = GetStringLitteral()
            {
                left = new ConstantExpression(s);
            }
        ) 
        | 
        (
            t = <DECIMAL_LITERAL>
            {
            	left = ConstantExpression.CreateFromDecimal(t.image);
            }    
        ) 
        | 
        (
            t = <HEX_LITERAL>
            {
            	left = ConstantExpression.CreateFromHex(t.image);
            }    
        ) 
        | 
        (
            t = <OCTAL_LITERAL>
            {
            	left = ConstantExpression.CreateFromOctal(t.image);
            }    
        ) 
        | 
        (
            t = <FLOATING_POINT_LITERAL>
            {
            	left = ConstantExpression.CreateFloat(t.image);
            }    
        ) 
        | 
        (
            <TRUE>
            {
                left = ConstantExpression.TRUE;
            }    
        ) 
        | 
        (
            <FALSE>
            {
                left = ConstantExpression.FALSE;
            }    
        ) 
        | 
        (
            <NULL>
            {
                left = ConstantExpression.NULL;
            }    
        )
    )
    {
        return left;
    }
}

string GetStringLitteral() :
{
    Token t;
    StringBuilder rc = new StringBuilder();
}
{
    t = <STRING_LITERAL> 
    {
    	// Decode the sting value.
    	String image = t.image;
    	for(int c = 1; c < image.Length - 1; c++)
        {
    		char ch = image[c];
    		if(ch == '\'')
            {
    			c++;    			
            }
   			rc.Append(ch);
    	}
	    return rc.ToString();
    }    
}

PropertyExpression GetVariable() :
{
    Token t;
    PropertyExpression left = null;
}
{
    ( 
        t = <ID> 
        {
            left = new PropertyExpression(t.image);
        }    
    )
    {
        return left;
    }
}
