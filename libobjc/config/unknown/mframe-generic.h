/* See ../README for copyright */

#define	MFRAME_STACK_STRUCT	0
#define	MFRAME_STRUCT_BYREF	0
#define MFRAME_SMALL_STRUCT	8
#define MFRAME_ARGS_SIZE	128
#define MFRAME_RESULT_SIZE	128

#define MFRAME_GET_STRUCT_ADDR(ARGS, TYPES) \
(((*(TYPES)==_C_STRUCT_B || *(TYPES)==_C_UNION_B || *(TYPES)==_C_ARY_B) && \
    objc_sizeof_type(TYPES) > MFRAME_SMALL_STRUCT) ? \
      *(void**)((ARGS)->arg_ptr + sizeof(void*)) : (void*)0)

#define MFRAME_SET_STRUCT_ADDR(ARGS, TYPES, ADDR) \
({if ((*(TYPES)==_C_STRUCT_B || *(TYPES)==_C_UNION_B || \
    *(TYPES)==_C_ARY_B) && \
    objc_sizeof_type(TYPES) > MFRAME_SMALL_STRUCT) \
      *(void**)((ARGS)->arg_ptr + sizeof(void*)) = (ADDR);})

#define MFRAME_ARGS int

#define MFRAME_INIT_ARGS(CUM, RTYPE)	\
((CUM) = ((*(RTYPE)==_C_STRUCT_B || *(RTYPE)==_C_UNION_B || \
    *(RTYPE)==_C_ARY_B) && \
    objc_sizeof_type(RTYPE) > MFRAME_SMALL_STRUCT) \
    ? sizeof(void*) : 0)

#define MFRAME_ARG_ENCODING(CUM, TYPE, STACK, DEST) \
({  \
  const char* type = (TYPE); \
  int align = objc_alignof_type(type); \
  int size = objc_sizeof_type(type); \
\
  (CUM) = ROUND((CUM), align); \
  (TYPE) = objc_skip_typespec(type); \
  sprintf((DEST), "%.*s%d", (int) ((TYPE)-type), type, (CUM)); \
  if (*(TYPE) == '+') \
    { \
      (TYPE)++; \
    } \
  while (isDigit (*(TYPE))) \
    { \
      (TYPE)++; \
    } \
  (DEST)=&(DEST)[strlen(DEST)]; \
  if ((*type==_C_STRUCT_B || *type==_C_UNION_B || *type==_C_ARY_B)) \
    { \
      (STACK) = (CUM) + ROUND(size, align); \
    } \
  else \
    { \
      (STACK) = (CUM) + size; \
    } \
  (CUM) += ROUND(size, sizeof(void*)); \
})

