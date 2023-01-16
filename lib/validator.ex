defmodule Unreal.Validator do
  defstruct [:value, :type, :errors]

  # Regex hell starts here
  # https://ihateregex.io/
  @regex_credit_card ~r/(^4[0-9]{12}(?:[0-9]{3})?$)|(^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$)|(3[47][0-9]{13})|(^3(?:0[0-5]|[68][0-9])[0-9]{11}$)|(^6(?:011|5[0-9]{2})[0-9]{12}$)|(^(?:2131|1800|35\d{3})\d{11}$)/
  @regex_bitcoin_adress ~r/^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,39}$/
  @regex_uuid ~r/^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/
  @regex_email ~r/(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  @regex_slug ~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/
  @regex_phone_number ~r/^\+[1-9]\d{1,14}$/
  @regex_url ~r/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()!@:%_\+.~#?&\/\/=]*) /
  @regex_mac_adress ~r/^[a-fA-F0-9]{2}(:[a-fA-F0-9]{2}){5}$/
  # Regex hell ends here

  @type value :: struct | map
  @type error :: {atom, String.t()}
  @type t :: %__MODULE__{
          value: value,
          errors: keyword(String.t())
        }

  @spec start(any, any, list(atom)) :: t()
  def start(value, type, params) do
    string_params = params |> Enum.map(&Atom.to_string/1)

    %__MODULE__{
      value:
        value
        |> Map.filter(fn {key, _value} -> key in string_params end)
        |> Map.new(fn {key, value} ->
          {String.to_existing_atom(key), value}
        end),
      type: type,
      errors: []
    }
  end

  @spec put_error(t, atom, String.t()) :: t
  def put_error(validator, error, reason) do
    %{validator | errors: Keyword.put(validator.errors, error, reason)}
  end

  @spec not_null(t, atom) :: t
  def not_null(validator, key) do
    if is_nil(validator.value[key]) do
      validator
      |> put_error(key, "Required field #{key} is not nullable.")
    else
      validator
    end
  end

  @spec load(t, atom, {module, atom, list}) :: t
  def load(validator, key, {module, f, args}) do
    result = apply(module, f, [validator.value[key] | args])

    if result === true do
      validator
    else
      validator
      |> put_error(key, result || "Field #{key} got an invalid value.")
    end
  end

  @spec range(t, atom, Range.t()) :: t
  def range(validator, key, range) do
    error = "Field #{key} is not in range (#{range.first} to #{range.last})."
    value = validator.value[key]

    if is_binary(value) do
      if String.length(value) >= range.first and String.length(value) <= range.last do
        validator
      else
        validator
        |> put_error(key, error)
      end
    else
      if value >= range.first and value <= range.last do
        validator
      else
        validator
        |> put_error(key, error)
      end
    end
  end

  @spec minimum(t, atom, any) :: t
  def minimum(validator, key, min) do
    error = "Field #{key} is bigger than minimum (#{min})."
    value = validator.value[key]

    if is_binary(value) do
      if String.length(value) >= min do
        validator
      else
        validator
        |> put_error(key, error)
      end
    else
      if value >= min do
        validator
      else
        validator
        |> put_error(key, error)
      end
    end
  end

  @spec maximum(t, atom, any) :: t
  def maximum(validator, key, max) do
    error = "Field #{key} is bigger than maximum (#{max})."
    value = validator.value[key]

    if is_binary(value) do
      if String.length(value) <= max do
        validator
      else
        validator
        |> put_error(key, error)
      end
    else
      if value <= max do
        validator
      else
        validator
        |> put_error(key, error)
      end
    end
  end

  @spec is_instance(t, atom, any) :: t
  def is_instance(validator, key, instance) do
    if is_struct(validator.value[key], instance) do
      validator
    else
      validator
      |> put_error(key, "Field #{key} got an invalid value.")
    end
  end

  @spec same(t, atom, atom) :: t
  def same(validator, key, other) do
    first = validator.value[key]
    second = validator.value[other]

    if first === second do
      validator
    else
      validator
      |> put_error(key, "Field #{key} doesn't match with field #{other}.")
    end
  end

  @spec match(t, atom, :credit_card) :: t
  def match(validator, key, :credit_card), do: match(validator, key, @regex_credit_card)

  @spec match(t, atom, :bitcoin_adress) :: t
  def match(validator, key, :bitcoin_adress), do: match(validator, key, @regex_bitcoin_adress)

  @spec match(t, atom, :uuid) :: t
  def match(validator, key, :uuid), do: match(validator, key, @regex_uuid)

  @spec match(t, atom, :email) :: t
  def match(validator, key, :email), do: match(validator, key, @regex_email)

  @spec match(t, atom, :slug) :: t
  def match(validator, key, :slug), do: match(validator, key, @regex_slug)

  @spec match(t, atom, :phone_number) :: t
  def match(validator, key, :phone_number), do: match(validator, key, @regex_phone_number)

  @spec match(t, atom, :url) :: t
  def match(validator, key, :url), do: match(validator, key, @regex_url)

  @spec match(t, atom, :mac_adress) :: t
  def match(validator, key, :mac_adress), do: match(validator, key, @regex_mac_adress)

  @spec match(t, atom, Regex.t()) :: t
  def match(validator, key, regex) do
    error = "Field #{key} got an invalid format."
    value = validator.value[key]

    if is_binary(value) do
      if Regex.match?(regex, value) do
        validator
      else
        validator
        |> put_error(key, error)
      end
    else
      validator
      |> put_error(key, error)
    end
  end

  @spec error(t) :: error | nil
  def error(validator) do
    List.first(validator.errors)
  end

  @spec cast(t) :: any
  def cast(validator) do
    struct(validator.type, Map.to_list(validator.value))
  end
end
