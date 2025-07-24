# 📊 Plantilla Excel para Importar Productos (Español)

## ✅ Formato Correcto del Excel

Tu archivo Excel debe tener exactamente estas columnas en la **primera fila**:

| nombre | precio | categoria | unidad | codigo | descripcion |
|--------|--------|-----------|---------|---------|-------------|
| Salmón Fresco | 25.50 | Pescado | kg | SAL001 | Salmón fresco del Atlántico |
| Lubina Entera | 18.90 | Pescado | kg | LUB001 | Lubina entera de primera calidad |
| Lechuga Romana | 2.40 | Verdura | unidad | LEC001 | Lechuga romana fresca |
| Tomate Pera | 3.20 | Verdura | kg | TOM001 | Tomate pera maduro |

## 🔧 Especificaciones:

### ✅ Columnas OBLIGATORIAS:
- **nombre**: Nombre del producto
- **precio**: Precio en euros (usar punto o coma decimal)

### ✅ Columnas OPCIONALES:
- **categoria**: Categoría del producto
- **unidad**: Unidad de medida (kg, unidad, litro, etc.)
- **codigo**: Código SKU del producto
- **descripcion**: Descripción del producto

## 🌐 Compatibilidad:

El sistema también acepta nombres en **inglés** para mantener compatibilidad:
- nombre = name
- precio = price
- categoria = category
- unidad = unit
- codigo = sku
- descripcion = description

## ⚠️ Notas Importantes:

1. **Primera fila**: Debe contener EXACTAMENTE los nombres de las columnas
2. **Precios**: Usar formato decimal (25.50 o 25,50)
3. **Sin espacios**: No dejar filas vacías entre los datos
4. **Formato**: Guardar como .xlsx (Excel)

## 🎯 Ejemplo de Archivo Excel:

```
nombre          | precio | categoria | unidad | codigo | descripcion
Salmón Fresco   | 25.50  | Pescado   | kg     | SAL001 | Salmón fresco del Atlántico
Lubina Entera   | 18.90  | Pescado   | kg     | LUB001 | Lubina entera de primera
Lechuga Romana  | 2.40   | Verdura   | unidad | LEC001 | Lechuga romana fresca
Tomate Pera     | 3.20   | Verdura   | kg     | TOM001 | Tomate pera maduro
```

## 🚀 ¡Listo!

Con este formato, tu archivo Excel funcionará perfectamente en RestauPedidos.
